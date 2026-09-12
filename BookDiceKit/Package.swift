// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookDiceKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BookDiceKit", targets: ["BookDiceKit"])
    ],
    targets: [
        .target(name: "BookDiceKit"),
        .testTarget(name: "BookDiceKitTests", dependencies: ["BookDiceKit"]),
    ]
)
