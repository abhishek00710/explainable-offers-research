import Foundation
import OfferCore
import Evaluation

struct Row: Codable { let transaction: Transaction; let label: SpendingCategory; let caseID: String; let condition: String }
struct Plan: Codable { let seed: Int; let rate: Int; let assigned: [String: SpendingCategory] }
struct Scenario: Codable {
 let id: String; let cohort: String; let accountID: String; let transactions: [Transaction]
 let offers: [Offer]; let snapshot: EligibilitySnapshot?; let expectedEligible: [String]; let judgments: [String: Int]
}
func load<T: Decodable>(_ path: String) throws -> T { try JSONDecoder().decode(T.self, from: Data(contentsOf: URL(fileURLWithPath: path))) }
func csv(_ a: [String]) -> String { a.map { "\""+$0.replacingOccurrences(of: "\"", with: "\"\"")+"\"" }.joined(separator: ",") }
func f(_ d: Double) -> String { String(format: "%.9f", locale: Locale(identifier: "en_US_POSIX"), d) }
func write(_ rows: [[String]], _ name: String, _ out: String) throws { try (rows.map(csv).joined(separator: "\n")+"\n").write(toFile: out+"/"+name, atomically: true, encoding: .utf8) }
func run() throws {
 let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "results"
 try FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)
 let data: [Row] = try load("../results/dataset.json")
 let plans: [Plan] = try load("inputs/plans.json")
 let methods = ["metadata","tokens","combined","conflict_abstain"]
 var summaries = [["experiment","seed","rate","method","scope","n","correct","classified_n","accuracy","coverage","abstention","macro_f1_known","macro_f1_six","micro_f1_known","micro_f1_six","macro_precision_known","macro_recall_known"]]
 var classes = [["experiment","seed","rate","method","scope","class","n","support","tp","fp","fn","precision","recall","f1"]]
 var confusion = [["experiment","seed","rate","method","scope","truth","prediction","count"]]
 var assignments = [["seed","rate","controlled_n","controlled_wrong","structured_n","structured_wrong"]]
 let predictionURL = URL(fileURLWithPath: out+"/predictions.csv")
 try Data((csv(["experiment","seed","rate","method","id","truth","prediction","source","controlled"])+"\n").utf8).write(to: predictionURL)
 let handle = try FileHandle(forWritingTo: predictionURL); try handle.seekToEnd()
 defer { try? handle.close() }
 let pool = Set(plans[0].assigned.keys)
 for plan in [Plan(seed: -1, rate: -1, assigned: [:])] + plans {
  let experiment = plan.seed == -1 ? "original" : "sensitivity"
  let prefix = [experiment,"\(plan.seed)","\(plan.rate)"]
  let transactions = data.map { row -> Transaction in
   var t = row.transaction
   if let category = plan.assigned[t.id] { t.structuredCategory = category }; return t
  }
  let structured = transactions.indices.filter { transactions[$0].structuredCategory != nil && transactions[$0].structuredCategory != .unknown }
  assignments.append(["\(plan.seed)","\(plan.rate)","\(pool.count)","\(transactions.indices.filter { pool.contains(transactions[$0].id) && transactions[$0].structuredCategory != data[$0].label }.count)","\(structured.count)","\(structured.filter { transactions[$0].structuredCategory != data[$0].label }.count)"])
  for method in methods {
   let predictions = transactions.map { method == "conflict_abstain" ? ConflictAware.classify($0) : Classifier().classify($0, method: ClassificationMethod(rawValue: method)!) }
   let lines = data.indices.map { i in csv(prefix+[method,data[i].transaction.id,data[i].label.rawValue,predictions[i].category.rawValue,predictions[i].source,pool.contains(data[i].transaction.id) ? "1":"0"]) }.joined(separator: "\n")+"\n"
   try handle.write(contentsOf: Data(lines.utf8))
   for scope in ["all","known_truth","controlled","classified"] {
    let indices = data.indices.filter { i in
     switch scope { case "known_truth": return data[i].label != .unknown
     case "controlled": return pool.contains(data[i].transaction.id)
     case "classified": return predictions[i].category != .unknown
     default: return true }
    }
    let truth = indices.map { data[$0].label }, predicted = indices.map { predictions[$0].category }
    let ms = SpendingCategory.allCases.map { Metrics.perClass(truth: truth, predictions: predicted, category: $0) }
    let known = Array(ms.prefix(5)), correct = zip(truth,predicted).filter { $0 == $1 }.count
    let covered = predicted.filter { $0 != .unknown }.count, n = indices.count
    let knownF1 = known.map(\.f1).reduce(0,+)/5, sixF1 = ms.map(\.f1).reduce(0,+)/6
    summaries.append(prefix+[method,scope,"\(n)","\(correct)","\(covered)",n == 0 ? "NA":f(Double(correct)/Double(n)),n == 0 ? "NA":f(Double(covered)/Double(n)),n == 0 ? "NA":f(1-Double(covered)/Double(n)),f(knownF1),f(sixF1),f(Metrics.micro(known).f1),f(Metrics.micro(ms).f1),f(known.map(\.precision).reduce(0,+)/5),f(known.map(\.recall).reduce(0,+)/5)])
    for (category,m) in zip(SpendingCategory.allCases,ms) {
     classes.append(prefix+[method,scope,category.rawValue,"\(n)","\(m.support)","\(m.tp)","\(m.fp)","\(m.fn)",f(m.precision),f(m.recall),f(m.f1)])
    }
    for t in SpendingCategory.allCases { for p in SpendingCategory.allCases {
     confusion.append(prefix+[method,scope,t.rawValue,p.rawValue,"\(zip(truth,predicted).filter { $0 == t && $1 == p }.count)"])
    } }
   }
  }
  print("Measured \(experiment) seed=\(plan.seed) controlled-rate=\(plan.rate)")
 }
 try write(summaries,"classification-summary.csv",out); try write(classes,"per-class.csv",out)
 try write(confusion,"confusion.csv",out); try write(assignments,"interventions.csv",out)
 let scenarios: [Scenario] = try load("inputs/ranking-expanded.json")
 var ranking = [["cohort","scenario","method","expected_n","returned_n","eligible_set_pass","order","ndcg_at_3","precision_at_3","quality_status"]]
 for s in scenarios {
  for method in ["eligible_id"]+methods {
   let p = try method == "conflict_abstain" ? ConflictAware.profile(s.transactions,accountID:s.accountID,now:1_800_000_000) : ProfileBuilder.build(s.transactions,accountID:s.accountID,now:1_800_000_000,method:ClassificationMethod(rawValue:method) ?? .metadata)
   let result = Ranker.recommend(offers:s.offers,snapshot:s.snapshot,profile:p,accountID:s.accountID,now:1_800_000_000,personalized:method != "eligible_id")
   let order=result.items.map { $0.offer.id }, expected=Set(s.expectedEligible)
   let passed = Set(order)==expected && Set(order).count==order.count
   let judgments=s.judgments.filter { expected.contains($0.key) }
   let defined = !expected.isEmpty && judgments.values.contains { $0 > 0 }
   let ndcg=defined ? f(Metrics.ndcg(order:order,judgments:judgments,k:3)) : "NA"
   let precision=defined ? f(Metrics.precisionAtK(order:order,judgments:judgments,k:3)) : "NA"
   ranking.append([s.cohort,s.id,method,"\(expected.count)","\(order.count)",passed ? "1":"0",order.joined(separator:" "),ndcg,precision,defined ? "defined" : (expected.isEmpty ? "no_eligible_candidates":"zero_ideal_gain")])
  }
 }
 try write(ranking,"ranking.csv",out)
 let environment:[String:String] = ["runUTC":ISO8601DateFormatter().string(from:Date()),"macOS":ProcessInfo.processInfo.operatingSystemVersionString,"processorCount":"\(ProcessInfo.processInfo.processorCount)","fixedClock":"1800000000","timing":"No new latency benchmark; conflict adapter is not optimized; original timings remain separate."]
 let encoder=JSONEncoder(); encoder.outputFormatting=[.prettyPrinted,.sortedKeys]
 try encoder.encode(environment).write(to:URL(fileURLWithPath:out+"/environment.json"))
 print("Completed 41 datasets × 4 methods; 24 scenarios × 5 rankers. No new timing claims.")
}
do { try run() } catch { print("VALIDATION FAILED: \(error)"); exit(1) }
