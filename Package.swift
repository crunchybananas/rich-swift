// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RichSwift",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "RichSwift", targets: ["RichSwift"]),
        .library(name: "RichSwiftLog", targets: ["RichSwiftLog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "RichSwift",
            dependencies: []
        ),
        .target(
            name: "RichSwiftLog",
            dependencies: [
                "RichSwift",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "RichSwiftTests",
            dependencies: ["RichSwift"]
        ),
        .executableTarget(
            name: "Demo",
            dependencies: ["RichSwift"],
            path: "Examples/Demo"
        ),
        .executableTarget(
            name: "LiveDemo",
            dependencies: ["RichSwift"],
            path: "Examples/LiveDemo"
        ),
    ]
)
