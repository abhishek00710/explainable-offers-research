import Foundation
import OfferCore

public struct MerchantCase: Codable, Sendable {
    public let caseID: String
    public let label: SpendingCategory
    public let description: String
    public let merchantID: String?
    public let structuredCategory: SpendingCategory?
    public let condition: String
}
public struct LabeledTransaction: Codable, Equatable, Sendable {
    public let transaction: Transaction
    public let label: SpendingCategory
    public let caseID: String
    public let condition: String
}
public struct RankingScenario: Codable, Sendable {
    public let id: String
    public let transactions: [Transaction]
    public let offers: [Offer]
    public let decisions: [String: Eligibility]
    public let judgments: [String: Int]
}
public struct SplitMix64 {
    private var state: UInt64
    public init(seed: UInt64) { state = seed }
    public mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
public enum Generator {
    public static let clock: Int64 = 1_800_000_000
    public static func catalog() throws -> [MerchantCase] { try resource("catalog") }
    public static func rankingScenarios() throws -> [RankingScenario] { try resource("ranking") }
    private static func resource<T: Decodable>(_ name: String) throws -> T {
        let url = Bundle.module.url(forResource: name, withExtension: "json")!
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }
    public static func generate(count: Int, seed: UInt64) throws -> [LabeledTransaction] {
        precondition(count >= 0)
        let cases = try catalog()
        var rng = SplitMix64(seed: seed)
        let prefixes = ["", "POS ", "CARD PURCHASE * ", "PAYPAL * ", "SQ * ", "DEBIT / "]
        return (0..<count).map { i in
            let c = cases[i % cases.count]
            let prefix = prefixes[Int(rng.next() % UInt64(prefixes.count))]
            let amount = Int64(100 + rng.next() % 20000)
            let age = Int64(rng.next() % UInt64(29 * 86400))
            let description = prefix + c.description + (rng.next() % 2 == 0 ? " #\(100 + i % 900)" : "")
            let t = Transaction(id: "s\(seed)-\(i)", timestamp: clock - age, amountCents: amount,
                                description: description, merchantID: c.merchantID, structuredCategory: c.structuredCategory)
            // Label is copied verbatim from an authored merchant case, before any classification.
            return LabeledTransaction(transaction: t, label: c.label, caseID: c.caseID, condition: c.condition)
        }
    }
}
