import Foundation

public enum SpendingCategory: String, Codable, CaseIterable, Sendable {
    case groceries, dining, transport, shopping, utilities, unknown
}
public enum PostingStatus: String, Codable, Sendable { case posted, pending, refunded, reversed }
public struct Transaction: Codable, Equatable, Sendable {
    public var id: String
    public var accountID: String
    public var timestamp: Int64
    public var amountCents: Int64
    public var currency: String
    public var description: String
    public var merchantID: String?
    public var structuredCategory: SpendingCategory?
    public var status: PostingStatus
    public var reversesID: String?
    public init(id: String, accountID: String = "A", timestamp: Int64 = 1_800_000_000,
                amountCents: Int64 = 1000, currency: String = "USD", description: String = "",
                merchantID: String? = nil, structuredCategory: SpendingCategory? = nil,
                status: PostingStatus = .posted, reversesID: String? = nil) {
        self.id = id; self.accountID = accountID; self.timestamp = timestamp
        self.amountCents = amountCents; self.currency = currency; self.description = description
        self.merchantID = merchantID; self.structuredCategory = structuredCategory
        self.status = status; self.reversesID = reversesID
    }
}
public struct Classification: Codable, Equatable, Sendable {
    public var category: SpendingCategory
    public var source: String
    public var evidence: String
    public init(_ category: SpendingCategory, _ source: String, _ evidence: String) {
        self.category = category; self.source = source; self.evidence = evidence
    }
}
public enum ClassificationMethod: String, CaseIterable, Sendable { case metadata, tokens, combined }
