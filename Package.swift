// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "A2UIFieldMiniApps",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "A2UIRuntime", targets: ["A2UIRuntime"])
    ],
    targets: [
        .target(
            name: "A2UIRuntime",
            path: "Sources/A2UIRuntime",
            resources: []
        )
    ]
)
