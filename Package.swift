// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PomoTimer",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "PomoTimer")
    ]
)
