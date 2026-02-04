// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "../../")  // RichSwift
    ],
    targets: [
        .executableTarget(
            name: "Benchmarks",
            dependencies: [
                .product(name: "RichSwift", package: "rich-swift")
            ],
            path: "Sources"
        )
    ]
)
