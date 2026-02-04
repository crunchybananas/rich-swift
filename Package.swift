// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RichSwift",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "RichSwift", targets: ["RichSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RichSwift",
            dependencies: []
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
    ]
)
