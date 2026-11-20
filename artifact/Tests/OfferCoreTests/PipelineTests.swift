import XCTest
@testable import OfferCore
import SyntheticData
import Evaluation

final class PipelineTests: XCTestCase {
    let now = Generator.clock
    func profile(_ ts: [Transaction] = []) throws -> SpendingProfile { try ProfileBuilder.build(ts, accountID: "A", now: now) }
    func snapshot(_ decision: Eligibility = .eligible) -> EligibilitySnapshot {
        EligibilitySnapshot(accountID: "A", issuedAt: now - 10, expiresAt: now + 100, decisions: ["o": decision])
    }
    func offer() -> Offer { Offer(id: "o", category: .groceries, validFrom: now - 100, validUntil: now + 100) }
    func testNativeTokenizerAndAliases() {
        XCTAssertEqual(WordTokenizer.words("POS * CAFÉ, #42"), ["pos", "cafe", "42"])
        for text in ["SQ * COFEE", "Harbor Café!", "coffee"] {
            XCTAssertEqual(Classifier().tokens(Transaction(id: "t", description: text)).category, .dining)
        }
    }
    func testAmbiguityOOVAndWordBoundaries() {
        for text in ["Metro Cafe", "ZXQ889", "coffeemaker", ""] {
            XCTAssertEqual(Classifier().tokens(Transaction(id: "t", description: text)).category, .unknown)
        }
    }
    func testCombinedPriorityAndFallback() {
        var t = Transaction(id: "t", description: "Cafe", structuredCategory: .groceries)
        XCTAssertEqual(Classifier().classify(t, method: .combined).category, .groceries)
        t.structuredCategory = .unknown
        XCTAssertEqual(Classifier().classify(t, method: .combined).category, .dining)
        t.merchantID = "m-t"
        XCTAssertEqual(Classifier().classify(t, method: .combined).category, .transport)
    }
    func testDuplicateAndConflictAreOrderIndependent() throws {
        let a = Transaction(id: "x", structuredCategory: .groceries)
        XCTAssertEqual(try profile([a,a]).totals[.groceries], 1000)
        var conflict = a; conflict.amountCents = 8000
        XCTAssertTrue(try profile([a,conflict]).contributions.isEmpty)
        XCTAssertTrue(try profile([conflict,a]).contributions.isEmpty)
    }
    func testRefundReversalPendingAndNegative() throws {
        let purchase = Transaction(id: "p", structuredCategory: .dining)
        for state in [PostingStatus.refunded, .reversed, .pending] {
            var t = purchase; t.status = state
            XCTAssertTrue(try profile([t]).contributions.isEmpty)
        }
        var credit = Transaction(id: "r", amountCents: -500, reversesID: "p")
        XCTAssertTrue(try profile([purchase,credit]).contributions.isEmpty)
        credit.timestamp = now + 1
        XCTAssertEqual(try profile([purchase,credit]).contributions.count, 1)
        credit.timestamp = now; credit.accountID = "B"
        XCTAssertEqual(try profile([purchase,credit]).contributions.count, 1)
        XCTAssertTrue(try profile([Transaction(id: "credit", amountCents: -1)]).contributions.isEmpty)
    }
    func testScopesWindowAndUnknownAccounting() throws {
        let ts = [Transaction(id: "a", accountID: "B"), Transaction(id: "b", timestamp: now + 1),
                  Transaction(id: "c", timestamp: now - 30*86400 - 1), Transaction(id: "d", currency: "EUR"),
                  Transaction(id: "e", timestamp: now - 30*86400), Transaction(id: "f", amountCents: 0)]
        let p = try profile(ts)
        XCTAssertEqual(p.contributions.map(\.transactionID), ["e"])
        XCTAssertEqual(p.totals[.unknown], 1000); XCTAssertEqual(p.classifiedCents, 0)
        XCTAssertThrowsError(try ProfileBuilder.build([], accountID: "A", now: now, windowSeconds: -1))
    }
    func testOverflowFailsRatherThanWraps() {
        XCTAssertThrowsError(try profile([Transaction(id: "a", amountCents: Int64.max), Transaction(id: "b")]))
    }
    func testEligibilityCannotBeInferred() throws {
        let p = try profile([Transaction(id: "t", structuredCategory: .groceries)])
        for s in [nil, snapshot(.unknown), snapshot(.ineligible), EligibilitySnapshot(accountID: "A", issuedAt: now, expiresAt: now+1, decisions: [:])] {
            XCTAssertTrue(Ranker.recommend(offers: [offer()], snapshot: s, profile: p, accountID: "A", now: now).items.isEmpty)
        }
    }
    func testStaleFutureExpiredAndWrongAccountSnapshots() throws {
        let p = try profile()
        var stale = snapshot(); stale.issuedAt = now - 3600
        var future = snapshot(); future.issuedAt = now + 1
        var expired = snapshot(); expired.expiresAt = now
        var other = snapshot(); other.accountID = "B"
        for s in [stale,future,expired,other] {
            XCTAssertTrue(Ranker.recommend(offers: [offer()], snapshot: s, profile: p, accountID: "A", now: now).items.isEmpty)
        }
    }
    func testAccountSwitchAndProfileClockRequireRefresh() throws {
        let p = try profile()
        XCTAssertTrue(Ranker.recommend(offers: [offer()], snapshot: snapshot(), profile: p, accountID: "B", now: now).items.isEmpty)
        XCTAssertTrue(Ranker.recommend(offers: [offer()], snapshot: snapshot(), profile: p, accountID: "A", now: now+1).items.isEmpty)
    }
    func testOfferValidityCurrencyAndDuplicateConflicts() throws {
        let p = try profile()
        var expired = offer(); expired.validUntil = now
        var future = offer(); future.validFrom = now+1
        var currency = offer(); currency.currency = "EUR"
        for o in [expired,future,currency] {
            XCTAssertTrue(Ranker.recommend(offers: [o], snapshot: snapshot(), profile: p, accountID: "A", now: now).items.isEmpty)
        }
        XCTAssertTrue(Ranker.recommend(offers: [offer(),expired], snapshot: snapshot(), profile: p, accountID: "A", now: now).items.isEmpty)
        XCTAssertEqual(Ranker.recommend(offers: [offer(),offer()], snapshot: snapshot(), profile: p, accountID: "A", now: now).items.count, 1)
    }
    func testExplanationsAndNeutralFallback() throws {
        let p = try profile([Transaction(id: "x", structuredCategory: .groceries)])
        let r = Ranker.recommend(offers: [offer()], snapshot: snapshot(), profile: p, accountID: "A", now: now)
        XCTAssertEqual(r.items.first?.scoreCents, 1000)
        XCTAssertTrue(r.items[0].explanation.contains("1 recent groceries transactions totaling 1000 USD cents"))
        XCTAssertTrue(r.items[0].explanation.contains("structured"))
        let neutral = Ranker.recommend(offers: [offer()], snapshot: snapshot(), profile: try profile(), accountID: "A", now: now)
        XCTAssertEqual(neutral.items.first?.scoreCents, 0)
        XCTAssertTrue(neutral.items[0].explanation.contains("no spending-based preference"))
    }
    func testRankingAndStableTies() throws {
        let p = try profile([Transaction(id: "t", structuredCategory: .dining)])
        let offers = [offer(), Offer(id: "z", category: .dining, validFrom: now, validUntil: now+1)]
        let s = EligibilitySnapshot(accountID: "A", issuedAt: now, expiresAt: now+1, decisions: ["o": .eligible, "z": .eligible])
        XCTAssertEqual(Ranker.recommend(offers: offers, snapshot: s, profile: p, accountID: "A", now: now).items.map { $0.offer.id }, ["z","o"])
        XCTAssertEqual(Ranker.recommend(offers: offers.reversed(), snapshot: s, profile: p, accountID: "A", now: now, personalized: false).items.map { $0.offer.id }, ["o","z"])
    }
    func testHandCalculatedMetrics() {
        let m = Metrics.perClass(truth: [.dining,.dining,.groceries,.unknown], predictions: [.dining,.unknown,.dining,.unknown], category: .dining)
        XCTAssertEqual(m.tp, 1); XCTAssertEqual(m.fp, 1); XCTAssertEqual(m.fn, 1)
        XCTAssertEqual(m.precision, 0.5); XCTAssertEqual(m.recall, 0.5); XCTAssertEqual(m.f1, 0.5)
        XCTAssertEqual(Metrics.ndcg(order: ["a","b"], judgments: ["a":3,"b":1], k: 2), 1, accuracy: 1e-12)
        XCTAssertEqual(Metrics.ndcg(order: ["b","a"], judgments: ["a":3,"b":1], k: 2), (1+7/log2(3))/(7+1/log2(3)), accuracy: 1e-12)
        XCTAssertEqual(Metrics.precisionAtK(order: ["a"], judgments: ["a":3], k: 3), 1/3.0)
        XCTAssertEqual(Metrics.percentile([1,2,3,4], 0.5), 2)
    }
    func testSeededGenerationAndAuthoredLabels() throws {
        let a = try Generator.generate(count: 72, seed: 42)
        XCTAssertEqual(a, try Generator.generate(count: 72, seed: 42))
        XCTAssertNotEqual(a, try Generator.generate(count: 72, seed: 43))
        XCTAssertEqual(Set(a.map { $0.transaction.id }).count, 72)
        XCTAssertEqual(a.filter { $0.label == .groceries }.count, 12)
        let wrong = a.first { $0.caseID == "g6" }!
        XCTAssertEqual(wrong.label, .groceries)
        XCTAssertEqual(Classifier().metadata(wrong.transaction).category, .dining)
    }
    func testFrozenFixture() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let frozen = try JSONDecoder().decode([LabeledTransaction].self, from: Data(contentsOf: root.appendingPathComponent("Fixtures/frozen-seed42.json")))
        XCTAssertEqual(frozen, try Generator.generate(count: 72, seed: 42))
    }
}
