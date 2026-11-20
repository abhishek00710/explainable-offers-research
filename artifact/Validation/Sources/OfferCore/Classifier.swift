import Foundation

public struct Classifier: Sendable {
    public init() {}
    // Explicit synthetic merchant registry; this is not a trained classifier.
    private let identifiers: [String: SpendingCategory] = ["m-g": .groceries, "m-d": .dining,
        "m-t": .transport, "m-s": .shopping, "m-u": .utilities]
    public func metadata(_ transaction: Transaction) -> Classification {
        if let category = transaction.structuredCategory, category != .unknown {
            return Classification(category, "structured", "Provided structured category: \(category.rawValue)")
        }
        if let id = transaction.merchantID, let category = identifiers[id] {
            return Classification(category, "identifier", "Registered merchant ID: \(id)")
        }
        return Classification(.unknown, "abstain", "No recognized merchant metadata")
    }
}
