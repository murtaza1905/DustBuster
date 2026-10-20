// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DustBusterCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "DustBusterCore", targets: ["DustBusterCore"])
    ],
    targets: [
        .target(
            name: "DustBusterCore",
            resources: [.copy("Resources/cask-zap.json")]
        ),
        .testTarget(
            name: "DustBusterCoreTests",
            dependencies: ["DustBusterCore"],
            resources: [.copy("Fixtures")]
        )
    ]
)
