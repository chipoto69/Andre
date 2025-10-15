// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AndreApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AndreApp",
            targets: ["AndreApp"]
        )
    ],
    targets: [
        .target(
            name: "AndreApp",
            path: "Sources"
        ),
        .testTarget(
            name: "AndreAppTests",
            dependencies: ["AndreApp"],
            path: "Tests"
        )
    ]
)
