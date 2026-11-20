import Foundation
import OfferCore

public struct ClassMetrics {
    public let tp: Int
    public let fp: Int
    public let fn: Int
    public let support: Int
    public var precision: Double { Self.ratio(tp, tp + fp) }
    public var recall: Double { Self.ratio(tp, tp + fn) }
    public var f1: Double { Self.ratio(2 * tp, 2 * tp + fp + fn) }
    public static func ratio(_ n: Int, _ d: Int) -> Double { d == 0 ? 0 : Double(n) / Double(d) }
}
public enum Metrics {
    public static func perClass(truth: [SpendingCategory], predictions: [SpendingCategory], category: SpendingCategory) -> ClassMetrics {
        precondition(truth.count == predictions.count)
        var tp = 0, fp = 0, fn = 0
        for (t, p) in zip(truth, predictions) {
            if t == category && p == category { tp += 1 }
            if t != category && p == category { fp += 1 }
            if t == category && p != category { fn += 1 }
        }
        return ClassMetrics(tp: tp, fp: fp, fn: fn, support: tp + fn)
    }
    public static func micro(_ metrics: [ClassMetrics]) -> ClassMetrics {
        ClassMetrics(tp: metrics.map(\.tp).reduce(0,+), fp: metrics.map(\.fp).reduce(0,+),
                     fn: metrics.map(\.fn).reduce(0,+), support: metrics.map(\.support).reduce(0,+))
    }
    public static func ndcg(order: [String], judgments: [String: Int], k: Int) -> Double {
        precondition(k > 0 && Set(order).count == order.count)
        func dcg(_ grades: [Int]) -> Double {
            grades.prefix(k).enumerated().reduce(0) { $0 + (pow(2, Double($1.element)) - 1) / log2(Double($1.offset + 2)) }
        }
        let ideal = dcg(judgments.values.sorted(by: >))
        return ideal == 0 ? 0 : dcg(order.map { judgments[$0, default: 0] }) / ideal
    }
    public static func precisionAtK(order: [String], judgments: [String: Int], k: Int) -> Double {
        precondition(k > 0)
        return Double(order.prefix(k).filter { judgments[$0, default: 0] > 0 }.count) / Double(k)
    }
    public static func percentile(_ values: [Double], _ p: Double) -> Double {
        precondition(!values.isEmpty && p >= 0 && p <= 1)
        let sorted = values.sorted()
        return sorted[max(0, Int(ceil(p * Double(sorted.count))) - 1)]
    }
}
