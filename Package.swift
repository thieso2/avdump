// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "avdump",
    dependencies: [
        .package(url: "https://github.com/sunlubo/SwiftFFmpeg.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "avdump",
            dependencies: ["SwiftFFmpeg"])
    ]
)
