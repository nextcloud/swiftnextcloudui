// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SwiftNextcloudUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "SwiftNextcloudUI",
            targets: ["SwiftNextcloudUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/twostraws/CodeScanner.git", .upToNextMajor(from: "2.5.2")),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftNextcloudUI",
            dependencies: [
                "CodeScanner",
            ],
            swiftSettings: [
              .enableUpcomingFeature("StrictConcurrency")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"),
            ]),
        .testTarget(
            name: "SwiftNextcloudUITests",
            dependencies: ["SwiftNextcloudUI"],
            swiftSettings: [
              .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ]
)
