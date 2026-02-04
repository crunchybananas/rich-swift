// swift-tools-version:5.9
import PackageDescription

// This is an example SPM package showing how to integrate RichSwift
// with a headless AI agent like Peel

let package = Package(
    name: "PeelIntegrationExample",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "../../")  // RichSwift
    ],
    targets: [
        .executableTarget(
            name: "PeelAgent",
            dependencies: [
                .product(name: "RichSwift", package: "rich-swift")
            ],
            path: "Sources"
        )
    ]
)
