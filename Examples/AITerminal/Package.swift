// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AITerminal",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "AITerminal",
            dependencies: [
                .product(name: "RichSwift", package: "rich-swift")
            ],
            path: "Sources"
        )
    ]
)
