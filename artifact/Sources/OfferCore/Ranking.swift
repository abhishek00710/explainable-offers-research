import Foundation

public struct Offer: Codable, Equatable, Sendable {
    public var id: String
    public var category: SpendingCategory
    public var currency: String
    public var validFrom: Int64
    public var validUntil: Int64
    public init(id: String, category: SpendingCategory, currency: String = "USD", validFrom: Int64, validUntil: Int64) {
        self.id = id; self.category = category; self.currency = currency; self.validFrom = validFrom; self.validUntil = validUntil
    }
}
public enum Eligibility: String, Codable, Sendable { case eligible, ineligible, unknown }
public struct EligibilitySnapshot: Codable, Sendable {
    public var accountID: String
    public var issuedAt: Int64
    public var expiresAt: Int64
    public var decisions: [String: Eligibility]
    public init(accountID: String, issuedAt: Int64, expiresAt: Int64, decisions: [String: Eligibility]) {
        self.accountID = accountID; self.issuedAt = issuedAt; self.expiresAt = expiresAt; self.decisions = decisions
    }
}
public struct Recommendation: Sendable {
    public let offer: Offer
    public let scoreCents: Int64
    public let explanation: String
}
public struct RecommendationResult: Sendable {
    public let items: [Recommendation]
    public let message: String
}
public enum Ranker {
    public static func recommend(offers: [Offer], snapshot: EligibilitySnapshot?, profile: SpendingProfile,
                                 accountID: String, now: Int64, maxEligibilityAge: Int64 = 3600,
                                 personalized: Bool = true) -> RecommendationResult {
        func empty(_ message: String) -> RecommendationResult { RecommendationResult(items: [], message: message) }
        guard profile.accountID == accountID, profile.asOf == now else { return empty("Refresh the spending profile for the active account and clock.") }
        guard let snapshot, snapshot.accountID == accountID, snapshot.issuedAt <= now,
              snapshot.expiresAt > now, maxEligibilityAge > 0,
              snapshot.issuedAt > now - maxEligibilityAge else { return empty("Fresh authoritative eligibility is required; no offers shown.") }
        let groups = Dictionary(grouping: offers, by: \.id)
        var items: [Recommendation] = []
        for id in groups.keys.sorted() {
            let group = groups[id]!
            guard !id.isEmpty, group.allSatisfy({ $0 == group[0] }) else { continue }
            let offer = group[0]
            guard snapshot.decisions[id] == .eligible, offer.currency == profile.currency,
                  offer.validFrom <= now, now < offer.validUntil else { continue }
            let score = personalized && offer.category != .unknown ? profile.totals[offer.category, default: 0] : 0
            let matching = profile.contributions.filter { $0.classification.category == offer.category }
            let explanation: String
            if score > 0 {
                let sources = Set(matching.map { $0.classification.source }).sorted().joined(separator: ", ")
                explanation = "Eligible offer matched \(matching.count) recent \(offer.category.rawValue) transactions totaling \(score) \(profile.currency) cents over \(profile.windowSeconds / 86400) days. Evidence: \(sources). Eligibility checked at \(snapshot.issuedAt)."
            } else {
                explanation = "Authoritatively eligible offer; no spending-based preference applied. Eligibility checked at \(snapshot.issuedAt)."
            }
            items.append(Recommendation(offer: offer, scoreCents: score, explanation: explanation))
        }
        items.sort { $0.scoreCents == $1.scoreCents ? $0.offer.id < $1.offer.id : $0.scoreCents > $1.scoreCents }
        return RecommendationResult(items: items, message: items.isEmpty ? "No currently eligible, valid offers." : "Only currently eligible, valid offers are shown.")
    }
}
