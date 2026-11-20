import XCTest
@testable import OfferCore
import Evaluation
final class ValidationTests: XCTestCase {
 func testConflictAbstains() {
  let t=Transaction(id:"t",description:"Metro",structuredCategory:.groceries)
  XCTAssertEqual(ConflictAware.classify(t).category,.unknown)
  XCTAssertEqual(ConflictAware.classify(t).source,"conflict")
 }
 func testCorrectMetadataCanBeLost() {
  let t=Transaction(id:"t",description:"Coffee Warehouse",structuredCategory:.shopping)
  XCTAssertEqual(Classifier().metadata(t).category,.shopping)
  XCTAssertEqual(ConflictAware.classify(t).category,.unknown)
 }
 func testMissingEvidenceDoesNotCreateConflict() {
  XCTAssertEqual(ConflictAware.classify(Transaction(id:"t",description:"ZXQ",structuredCategory:.shopping)).category,.shopping)
  XCTAssertEqual(ConflictAware.classify(Transaction(id:"t",description:"Metro")).category,.transport)
  XCTAssertEqual(ConflictAware.classify(Transaction(id:"t",description:"Metro Coffee",structuredCategory:.shopping)).category,.shopping)
 }
 func testAgreementCanStillBeWrong() {
  XCTAssertEqual(ConflictAware.classify(Transaction(id:"t",description:"Coffee Foundation",structuredCategory:.dining)).category,.dining)
 }
 func testRegistryConflictsAlsoAbstain() {
  XCTAssertEqual(ConflictAware.classify(Transaction(id:"t",description:"Metro",merchantID:"m-g")).category,.unknown)
 }
 func testProfilePreservesLedgerGateAndUnknownTotals() throws {
  let t=Transaction(id:"t",description:"Metro",structuredCategory:.groceries)
  let p=try ConflictAware.profile([t,t,Transaction(id:"b",accountID:"B")],accountID:"A",now:1_800_000_000)
  XCTAssertEqual(p.contributions.count,1); XCTAssertEqual(p.totals[.unknown],1000)
  XCTAssertEqual(p.classifiedCents,0); XCTAssertEqual(p.exclusions["duplicate"],1)
  let reversed=try ConflictAware.profile([t,Transaction(id:"r",amountCents:-100,reversesID:"t")],accountID:"A",now:1_800_000_000)
  XCTAssertTrue(reversed.contributions.isEmpty)
 }
 func testConflictingDuplicatesStayExcluded() throws {
  var t=Transaction(id:"t",description:"Metro"); var other=t; other.amountCents=10
  t.structuredCategory = .groceries
  XCTAssertTrue(try ConflictAware.profile([t,other],accountID:"A",now:1_800_000_000).contributions.isEmpty)
 }
 func testNativeTokenEvidence() { XCTAssertEqual(WordTokenizer.words("POS * CAFÉ, #42"),["pos","cafe","42"]) }
 func testKnownMacroDefinitionAndUnknownDenominators() {
  let truth:[SpendingCategory]=[.groceries,.groceries,.dining,.unknown]
  let predictions:[SpendingCategory]=[.groceries,.unknown,.groceries,.unknown]
  let ms=SpendingCategory.allCases.map { Metrics.perClass(truth:truth,predictions:predictions,category:$0) }
  XCTAssertEqual(ms[0].tp,1); XCTAssertEqual(ms[0].fp,1); XCTAssertEqual(ms[0].fn,1)
  XCTAssertEqual(ms.prefix(5).map(\.f1).reduce(0,+)/5,0.1,accuracy:1e-10)
  XCTAssertEqual(ms.map(\.f1).reduce(0,+)/6,(0.5+2.0/3)/6,accuracy:1e-10)
  XCTAssertEqual(Metrics.micro(ms).f1,0.5,accuracy:1e-10)
  XCTAssertEqual(Metrics.micro(Array(ms.prefix(5))).f1,0.4,accuracy:1e-10)
 }
 func testRankingUsesIndependentIdealSet() {
  XCTAssertEqual(Metrics.ndcg(order:["b","a"],judgments:["a":3,"b":1],k:3),(1+7/log2(3))/(7+1/log2(3)),accuracy:1e-12)
  XCTAssertEqual(Metrics.precisionAtK(order:["a"],judgments:["a":3],k:3),1/3.0)
 }
}
