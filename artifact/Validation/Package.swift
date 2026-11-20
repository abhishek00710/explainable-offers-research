// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "OfferValidation", platforms: [.macOS(.v13)],
 products: [.executable(name: "validate-offers", targets: ["ValidationRunner"])],
 targets: [.target(name: "OfferCore"), .target(name: "Evaluation", dependencies: ["OfferCore"]),
 .executableTarget(name: "ValidationRunner", dependencies: ["OfferCore", "Evaluation"]),
 .testTarget(name: "ValidationTests", dependencies: ["OfferCore", "Evaluation"])])
