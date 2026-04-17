// swift-tools-version: 5.9
import PackageDescription

// This package exists solely to run unit tests against the pure-Swift layers
// (Models, Services, ViewModels) of the GuessRank app via `swift test`.
// The actual app is built with the GuessRank.xcodeproj Xcode project.
// Views and SwiftUI-dependent code are intentionally excluded from this package.
let package = Package(
    name: "GuessRankCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "GuessRankCore", targets: ["GuessRankCore"]),
    ],
    targets: [
        .target(
            name: "GuessRankCore",
            path: "GuessRank",
            exclude: [
                "Assets.xcassets",
                "GuessRankApp.swift",
                "ContentView.swift",
                "Views",
                "Services/HapticsService.swift",
            ],
            sources: ["Models", "Services", "ViewModels"]
        ),
        .testTarget(
            name: "GuessRankTests",
            dependencies: ["GuessRankCore"],
            path: "GuessRankTests"
        ),
    ]
)
