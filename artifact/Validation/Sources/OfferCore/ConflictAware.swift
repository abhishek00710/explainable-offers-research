import Foundation

/// Additive experimental policy; original files in this module are byte-identical copies.
public enum ConflictAware {
    public static func classify(_ transaction: Transaction) -> Classification {
        let c = Classifier(), metadata = c.metadata(transaction), tokens = c.tokens(transaction)
        if metadata.category != .unknown && tokens.category != .unknown && metadata.category != tokens.category {
            return Classification(.unknown, "conflict", "Metadata \(metadata.category.rawValue) disagrees with token evidence \(tokens.category.rawValue); abstained.")
        }
        return metadata.category == .unknown ? tokens : metadata
    }
    public static func profile(_ transactions: [Transaction], accountID: String, now: Int64) throws -> SpendingProfile {
        // Reuse the original ledger gate exactly. Reclassify only admitted contributions.
        let base = try ProfileBuilder.build(transactions, accountID: accountID, now: now)
        let scoped = Dictionary(grouping: transactions.filter { $0.accountID == accountID }, by: \.id)
        var totals: [SpendingCategory: Int64] = [:]
        let contributions = base.contributions.map { contribution in
            let result = classify(scoped[contribution.transactionID]![0])
            totals[result.category, default: 0] += contribution.amountCents
            return Contribution(transactionID: contribution.transactionID, amountCents: contribution.amountCents, classification: result)
        }
        return SpendingProfile(accountID: base.accountID, currency: base.currency, asOf: base.asOf,
            windowSeconds: base.windowSeconds, totals: totals, contributions: contributions, exclusions: base.exclusions)
    }
}
