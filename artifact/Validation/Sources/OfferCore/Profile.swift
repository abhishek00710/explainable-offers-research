import Foundation

public enum ProfileError: Error { case invalidWindow, amountOverflow }
public struct Contribution: Codable, Sendable {
    public let transactionID: String
    public let amountCents: Int64
    public let classification: Classification
}
public struct SpendingProfile: Sendable {
    public let accountID: String
    public let currency: String
    public let asOf: Int64
    public let windowSeconds: Int64
    public let totals: [SpendingCategory: Int64]
    public let contributions: [Contribution]
    public let exclusions: [String: Int]
    public var classifiedCents: Int64 { totals.filter { $0.key != .unknown }.values.reduce(0, +) }
}
public enum ProfileBuilder {
    public static func build(_ transactions: [Transaction], accountID: String, currency: String = "USD",
                             now: Int64, windowSeconds: Int64 = 30 * 86400, method: ClassificationMethod = .combined) throws -> SpendingProfile {
        guard windowSeconds > 0, now >= windowSeconds else { throw ProfileError.invalidWindow }
        var exclusions: [String: Int] = [:]
        func reject(_ reason: String, _ count: Int = 1) { exclusions[reason, default: 0] += count }
        let scoped = transactions.filter {
            if $0.accountID != accountID { reject("other_account"); return false }; return true
        }
        // Conflicting duplicate versions fail closed; exact duplicates count once. Stable ID order.
        let groups = Dictionary(grouping: scoped, by: \.id)
        var unique: [Transaction] = []
        for id in groups.keys.sorted() {
            let group = groups[id]!
            guard !id.isEmpty, group.allSatisfy({ $0 == group[0] }) else { reject("conflicting_or_empty_id", group.count); continue }
            unique.append(group[0]); if group.count > 1 { reject("duplicate", group.count - 1) }
        }
        // Inspect all scoped records, including conflicting duplicates, for cancellation links.
        // Conservative whole-purchase exclusion for partial refunds; no netting heuristic.
        let cancelled = Set(scoped.filter { $0.timestamp <= now && $0.status != .pending }.compactMap(\.reversesID))
        let classifier = Classifier()
        var totals: [SpendingCategory: Int64] = [:]
        var contributions: [Contribution] = []
        var allCents: Int64 = 0
        for t in unique {
            guard t.currency == currency else { reject("currency"); continue }
            guard t.timestamp >= now - windowSeconds && t.timestamp <= now else { reject("outside_window"); continue }
            guard t.status == .posted, t.amountCents > 0, t.reversesID == nil, !cancelled.contains(t.id) else { reject("non_spend_or_cancelled"); continue }
            let (newTotal, overflow) = allCents.addingReportingOverflow(t.amountCents)
            guard !overflow else { throw ProfileError.amountOverflow }; allCents = newTotal
            let result = classifier.classify(t, method: method)
            totals[result.category, default: 0] += t.amountCents
            contributions.append(Contribution(transactionID: t.id, amountCents: t.amountCents, classification: result))
        }
        return SpendingProfile(accountID: accountID, currency: currency, asOf: now, windowSeconds: windowSeconds,
                               totals: totals, contributions: contributions, exclusions: exclusions)
    }
}
