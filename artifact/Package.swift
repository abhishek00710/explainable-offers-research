// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "ExplainableOffers", platforms: [.macOS(.v13)],
    products: [.library(name: "OfferCore", targets: ["OfferCore"]), .executable(name: "offer-experiments", targets: ["Experiments"])],
    targets: [.target(name: "OfferCore"), .target(name: "SyntheticData", dependencies: ["OfferCore"], resources: [.process("Resources")]),
              .target(name: "Evaluation", dependencies: ["OfferCore"]),
              .executableTarget(name: "Experiments", dependencies: ["OfferCore", "SyntheticData", "Evaluation"]),
              .testTarget(name: "OfferCoreTests", dependencies: ["OfferCore", "SyntheticData", "Evaluation"])])
