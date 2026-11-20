import Foundation
import NaturalLanguage

public enum WordTokenizer {
    public static func words(_ text: String) -> [String] {
        let normalized = text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
        // Local instance: never shared across threads. English synthetic corpus only.
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.setLanguage(.english)
        tokenizer.string = normalized
        return tokenizer.tokens(for: normalized.startIndex..<normalized.endIndex).map { String(normalized[$0]) }
    }
}
extension Classifier {
    public func classify(_ transaction: Transaction, method: ClassificationMethod) -> Classification {
        switch method {
        case .metadata: return metadata(transaction)
        case .tokens: return tokens(transaction)
        case .combined:
            let result = metadata(transaction)
            return result.category == .unknown ? tokens(transaction) : result
        }
    }
    public func tokens(_ transaction: Transaction) -> Classification {
        // Reviewed explicit aliases, not learned weights or fuzzy matching.
        let rules: [(SpendingCategory, Set<String>)] = [
            (.groceries, ["grocer", "grocery", "groceries", "supermarket", "freshmart", "freshmrt"]),
            (.dining, ["cafe", "coffee", "restaurant", "bistro", "cofee"]),
            (.transport, ["metro", "transit", "rail", "taxi", "rideshare"]),
            (.shopping, ["apparel", "bookshop", "electronics", "boutique"]),
            (.utilities, ["electric", "water", "broadband", "utility"]) ]
        let words = Set(WordTokenizer.words(transaction.description))
        let matches = rules.compactMap { category, aliases -> (SpendingCategory, [String])? in
            let evidence = words.intersection(aliases).sorted()
            return evidence.isEmpty ? nil : (category, evidence)
        }
        guard matches.count == 1, let match = matches.first else {
            return Classification(.unknown, "abstain", matches.isEmpty ? "No explicit alias matched" : "Ambiguous aliases across categories")
        }
        return Classification(match.0, "tokens", "Explicit alias: " + match.1.joined(separator: ", "))
    }
}
