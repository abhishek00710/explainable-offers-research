import Foundation
import Darwin
import OfferCore
import SyntheticData
import Evaluation

func csv(_ fields: [String]) -> String { fields.map { "\"" + $0.replacingOccurrences(of: "\"", with: "\"\"") + "\"" }.joined(separator: ",") }
func f(_ value: Double) -> String { String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), value) }
func writeCSV(_ name: String, _ rows: [[String]], to dir: URL) throws {
    try (rows.map(csv).joined(separator: "\n") + "\n").write(to: dir.appendingPathComponent(name), atomically: true, encoding: .utf8)
}
func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
    let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(value).write(to: url)
}
func command(_ executable: String, _ args: [String]) -> String {
    let p = Process(); p.executableURL = URL(fileURLWithPath: executable); p.arguments = args
    let pipe = Pipe(); p.standardOutput = pipe; p.standardError = pipe
    do { try p.run(); let data = pipe.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
        return "exit=\(p.terminationStatus) " + (String(data: data, encoding: .utf8) ?? "undecodable")
    } catch { return "unavailable: \(error)" }
}
func run() throws {
    let args = Array(CommandLine.arguments.dropFirst())
    func option(_ key: String, default fallback: String) throws -> String {
        guard let i = args.firstIndex(of: key) else { return fallback }
        guard i+1 < args.count else { throw NSError(domain: "CLI: missing value for \(key)", code: 1) }
        return args[i+1]
    }
    let allowed = ["--seed", "--output", "--freeze", "--count"]
    guard args.count % 2 == 0, stride(from: 0, to: args.count, by: 2).allSatisfy({ allowed.contains(args[$0]) }) else {
        throw NSError(domain: "Usage: offer-experiments [--seed N] [--count N] [--output path] [--freeze path]", code: 1)
    }
    guard let seed = UInt64(try option("--seed", default: "20261119")),
          let count = Int(try option("--count", default: "2160")), count > 0 else { throw NSError(domain: "Invalid seed/count", code: 1) }
    if args.contains("--freeze") {
        let path = try option("--freeze", default: "Fixtures/frozen-seed42.json")
        try writeJSON(Generator.generate(count: count, seed: seed), to: URL(fileURLWithPath: path))
        print("Wrote explicit frozen fixture: \(path), n=\(count), seed=\(seed)"); return
    }
    let out = URL(fileURLWithPath: try option("--output", default: "results"), isDirectory: true)
    try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
    let data = try Generator.generate(count: count, seed: seed)
    try writeJSON(data, to: out.appendingPathComponent("dataset.json"))
    let classifier = Classifier()
    var table = "# Measured synthetic experiment tables\n\nSeed: \(seed). Fixed clock: \(Generator.clock). Classification records: \(count). No production data.\n\n"
    table += "## Classification\n\nAll-label accuracy includes correct unknown outcomes; classified accuracy excludes predicted unknown. Macro-F1 uses five spending classes.\n\n| Method | N | Classified N | All accuracy | Classified accuracy | Coverage | Abstention | Macro-F1 (all) |\n|---|---:|---:|---:|---:|---:|---:|---:|\n"
    var summary = [["method","n","classified_n","correct_all","correct_classified","accuracy_all","accuracy_classified","coverage","abstention","macro_f1_known_all"]]
    var detailed = [["method","scope","class","denominator","support","tp","fp","fn","precision","recall","f1"]]
    var predictionsCSV = [["method","transaction_id","case_id","condition","truth","prediction","source","evidence"]]
    var confusion = [["method","truth","prediction","count"]]
    var slices = [["method","condition","n","correct","classified","accuracy","coverage"]]
    for method in ClassificationMethod.allCases {
        let results = data.map { classifier.classify($0.transaction, method: method) }
        let pairs = Array(zip(data, results))
        let classified = pairs.filter { $0.1.category != .unknown }
        let correct = pairs.filter { $0.0.label == $0.1.category }.count
        let correctClassified = classified.filter { $0.0.label == $0.1.category }.count
        let accuracy = ClassMetrics.ratio(correct, count)
        let accuracyClassified = ClassMetrics.ratio(correctClassified, classified.count)
        let coverage = ClassMetrics.ratio(classified.count, count)
        let macro = SpendingCategory.allCases.filter { $0 != .unknown }.map {
            Metrics.perClass(truth: data.map(\.label), predictions: results.map(\.category), category: $0).f1
        }.reduce(0,+) / 5
        summary.append([method.rawValue,"\(count)","\(classified.count)","\(correct)","\(correctClassified)",f(accuracy),f(accuracyClassified),f(coverage),f(1-coverage),f(macro)])
        table += "| \(method.rawValue) | \(count) | \(classified.count) | \(f(accuracy)) | \(f(accuracyClassified)) | \(f(coverage)) | \(f(1-coverage)) | \(f(macro)) |\n"
        for (scope, selected) in [("all",pairs),("classified",classified)] {
            let metrics = SpendingCategory.allCases.map { Metrics.perClass(truth: selected.map { $0.0.label }, predictions: selected.map { $0.1.category }, category: $0) }
            for (category, m) in zip(SpendingCategory.allCases, metrics) {
                detailed.append([method.rawValue,scope,category.rawValue,"\(selected.count)","\(m.support)","\(m.tp)","\(m.fp)","\(m.fn)",f(m.precision),f(m.recall),f(m.f1)])
            }
            for (name, ms) in [("six",metrics),("known",Array(metrics.prefix(5)))] {
                let micro = Metrics.micro(ms)
                detailed.append([method.rawValue,scope,"micro_"+name,"\(selected.count)","\(micro.support)","\(micro.tp)","\(micro.fp)","\(micro.fn)",f(micro.precision),f(micro.recall),f(micro.f1)])
                detailed.append([method.rawValue,scope,"macro_"+name,"\(selected.count)","\(micro.support)","NA","NA","NA",f(ms.map(\.precision).reduce(0,+)/Double(ms.count)),f(ms.map(\.recall).reduce(0,+)/Double(ms.count)),f(ms.map(\.f1).reduce(0,+)/Double(ms.count))])
            }
        }
        for (row, result) in pairs {
            predictionsCSV.append([method.rawValue,row.transaction.id,row.caseID,row.condition,row.label.rawValue,result.category.rawValue,result.source,result.evidence])
        }
        for truth in SpendingCategory.allCases { for prediction in SpendingCategory.allCases {
            confusion.append([method.rawValue,truth.rawValue,prediction.rawValue,"\(pairs.filter { $0.0.label == truth && $0.1.category == prediction }.count)"])
        } }
        for condition in Set(data.map(\.condition)).sorted() {
            let selected = pairs.filter { $0.0.condition == condition }
            let n = selected.count, ok = selected.filter { $0.0.label == $0.1.category }.count
            let covered = selected.filter { $0.1.category != .unknown }.count
            slices.append([method.rawValue,condition,"\(n)","\(ok)","\(covered)",f(ClassMetrics.ratio(ok,n)),f(ClassMetrics.ratio(covered,n))])
        }
    }
    try writeCSV("classification-summary.csv", summary, to: out)
    try writeCSV("classification-by-class.csv", detailed, to: out)
    try writeCSV("predictions.csv", predictionsCSV, to: out)
    try writeCSV("confusion.csv", confusion, to: out)
    try writeCSV("classification-slices.csv", slices, to: out)
    var composition = [["label","condition","count"]]
    for label in SpendingCategory.allCases { for condition in Set(data.map(\.condition)).sorted() {
        let n = data.filter { $0.label == label && $0.condition == condition }.count
        if n > 0 { composition.append([label.rawValue,condition,"\(n)"]) }
    } }
    try writeCSV("composition.csv", composition, to: out)
    table += "\n## Per-class metrics on all records\n\n| Method | Class | Support | Precision | Recall | F1 |\n|---|---|---:|---:|---:|---:|\n"
    for row in detailed.dropFirst() where row[1] == "all" && SpendingCategory(rawValue: row[2]) != nil {
        table += "| \(row[0]) | \(row[2]) | \(row[4]) | \(row[8]) | \(row[9]) | \(row[10]) |\n"
    }
    table += "\n## Metrics on classified records only\n\nPredicted unknown rows are excluded; zero denominators map to zero.\n\n| Method | Class or summary | Selected N | Support | Precision | Recall | F1 |\n|---|---|---:|---:|---:|---:|---:|\n"
    for row in detailed.dropFirst() where row[1] == "classified" {
        table += "| \(row[0]) | \(row[2]) | \(row[3]) | \(row[4]) | \(row[8]) | \(row[9]) | \(row[10]) |\n"
    }
    table += "\n## Classification failure slices\n\n| Method | Condition | N | Accuracy | Coverage |\n|---|---|---:|---:|---:|\n"
    for row in slices.dropFirst() { table += "| \(row[0]) | \(row[1]) | \(row[2]) | \(row[5]) | \(row[6]) |\n" }
    let scenarios = try Generator.rankingScenarios()
    var ranking = [["scenario","method","eligible_n","order","ndcg_at_3","precision_at_3"]]
    var rankingSummary = [["method","scenario_n","mean_ndcg_at_3","mean_precision_at_3"]]
    table += "\n## Ranking (independent synthetic relevance; k=3)\n\n| Method | Scenarios | Mean NDCG@3 | Mean P@3 |\n|---|---:|---:|---:|\n"
    for name in ["eligible_id"] + ClassificationMethod.allCases.map(\.rawValue) {
        var ndcgs: [Double] = [], precisions: [Double] = []
        for scenario in scenarios {
            let method = ClassificationMethod(rawValue: name) ?? .metadata
            let profile = try ProfileBuilder.build(scenario.transactions, accountID: "A", now: Generator.clock, method: method)
            let snapshot = EligibilitySnapshot(accountID: "A", issuedAt: Generator.clock-10, expiresAt: Generator.clock+100, decisions: scenario.decisions)
            let result = Ranker.recommend(offers: scenario.offers, snapshot: snapshot, profile: profile, accountID: "A", now: Generator.clock, personalized: name != "eligible_id")
            let order = result.items.map { $0.offer.id }
            // Ideal ordering restricted to the identical eligible candidate set.
            let judgments = scenario.judgments.filter { order.contains($0.key) }
            let ndcg = Metrics.ndcg(order: order, judgments: judgments, k: 3)
            let precision = Metrics.precisionAtK(order: order, judgments: judgments, k: 3)
            ndcgs.append(ndcg); precisions.append(precision)
            ranking.append([scenario.id,name,"\(order.count)",order.joined(separator: " "),f(ndcg),f(precision)])
        }
        let ndcg = ndcgs.reduce(0,+)/Double(scenarios.count), precision = precisions.reduce(0,+)/Double(scenarios.count)
        rankingSummary.append([name,"\(scenarios.count)",f(ndcg),f(precision)])
        table += "| \(name) | \(scenarios.count) | \(f(ndcg)) | \(f(precision)) |\n"
    }
    table += "\n## Ranking by scenario\n\n| Scenario | Method | NDCG@3 | P@3 |\n|---|---|---:|---:|\n"
    for row in ranking.dropFirst() { table += "| \(row[0]) | \(row[1]) | \(row[4]) | \(row[5]) |\n" }
    try writeCSV("ranking.csv", ranking, to: out); try writeCSV("ranking-summary.csv", rankingSummary, to: out)
    // Timed region: deduplication, account/window filtering, classification, profile, eligibility and ranking.
    // Input generation, JSON/CSV I/O and environment capture are outside this region.
    let warmups = 2, trials = 9
    var raw = [["n","method","trial","elapsed_ms","checksum"]]
    var bench = [["n","method","warmups","trials","min_ms","median_ms","p90_ms","max_ms","mean_ms","sample_sd_ms"]]
    table += "\n## Release pipeline benchmark\n\nTwo warmups per size/method, nine measured trials, nearest-rank percentiles; milliseconds.\n\n| N | Method | Min | Median | P90 | Max | Mean | Sample SD |\n|---:|---|---:|---:|---:|---:|---:|---:|\n"
    let benchScenario = scenarios[0]
    let benchSnapshot = EligibilitySnapshot(accountID: "A", issuedAt: Generator.clock, expiresAt: Generator.clock+100, decisions: benchScenario.decisions)
    for n in [100,1000,10000] {
        let ts = try Generator.generate(count: n, seed: seed).map(\.transaction)
        var durations: [ClassificationMethod: [Double]] = [:]
        for trial in -warmups..<trials {
            // Rotate method order to reduce a fixed order bias; deterministic, not randomized statistical control.
            let rotation = (trial + warmups) % ClassificationMethod.allCases.count
            let methods = Array(ClassificationMethod.allCases[rotation...]) + Array(ClassificationMethod.allCases[..<rotation])
            for method in methods {
                let start = DispatchTime.now().uptimeNanoseconds
                let profile = try ProfileBuilder.build(ts, accountID: "A", now: Generator.clock, method: method)
                let result = Ranker.recommend(offers: benchScenario.offers, snapshot: benchSnapshot, profile: profile, accountID: "A", now: Generator.clock)
                let checksum = result.items.map(\.scoreCents).reduce(0,+) + Int64(profile.contributions.count)
                let elapsed = Double(DispatchTime.now().uptimeNanoseconds - start)/1e6
                if trial >= 0 { durations[method,default: []].append(elapsed); raw.append(["\(n)",method.rawValue,"\(trial)",f(elapsed),"\(checksum)"]) }
            }
        }
        for method in ClassificationMethod.allCases {
            let ds = durations[method]!, mean = ds.reduce(0,+)/Double(trials)
            let sd = sqrt(ds.map { pow($0-mean,2) }.reduce(0,+)/Double(trials-1))
            let values = [ds.min()!,Metrics.percentile(ds,0.5),Metrics.percentile(ds,0.9),ds.max()!,mean,sd].map(f)
            bench.append(["\(n)",method.rawValue,"\(warmups)","\(trials)"]+values)
            table += "| \(n) | \(method.rawValue) | " + values.joined(separator: " | ") + " |\n"
        }
        print("Completed benchmark n=\(n)")
    }
    try writeCSV("benchmark-trials.csv", raw, to: out); try writeCSV("benchmark-summary.csv", bench, to: out)
    var usage = rusage()
    let memoryResult = getrusage(RUSAGE_SELF, &usage)
    #if DEBUG
    let configuration = "debug"
    #else
    let configuration = "release"
    #endif
    let environment: [String: String] = [
        "seed":"\(seed)", "fixedClock":"\(Generator.clock)", "datasetCount":"\(count)",
        "runUTC": ISO8601DateFormatter().string(from: Date()),
        "swift":command("/usr/bin/xcrun",["swift","--version"]),
        "macOS":command("/usr/bin/sw_vers",[]), "architecture":command("/usr/bin/uname",["-m"]),
        "hardware":command("/usr/sbin/sysctl",["-n","machdep.cpu.brand_string","hw.memsize"]),
        "osVersion":ProcessInfo.processInfo.operatingSystemVersionString,
        "processorCount":"\(ProcessInfo.processInfo.processorCount)",
        "peakProcessRSSBytes":memoryResult == 0 ? "\(usage.ru_maxrss)" : "unavailable",
        "memoryScope":"Darwin getrusage RUSAGE_SELF ru_maxrss bytes: cumulative process high-water mark after all experiments, including data/output buffering; not per-method allocation or incremental memory.",
        "buildConfiguration": configuration,
        "arguments":CommandLine.arguments.joined(separator: " "),
        "timing":"DispatchTime monotonic uptime; pipeline only; 2 warmups and 9 measured trials; rotated method order"
    ]
    try writeJSON(environment, to: out.appendingPathComponent("environment.json"))
    try table.write(to: out.appendingPathComponent("tables.md"), atomically: true, encoding: .utf8)
    print("Completed classification N=\(count), ranking scenarios=\(scenarios.count), benchmark trials=\(raw.count-1). Results: \(out.path)")
}
do { try run() } catch { fputs("Experiment failed: \(error)\n", stderr); exit(1) }
