// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OurBigKitchen",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "OurBigKitchen", targets: ["OurBigKitchen"])
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.8.2")
    ],
    targets: [
        .target(
            name: "OurBigKitchen",
            dependencies: [
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "OurBigKitchen",
            exclude: [
                "OurBigKitchen.entitlements",
                "Features/Impact/ImpactView.swift.bak",
                "Features/Impact/ImpactView.swift.new"
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("OurBigKitchen.xcdatamodeld")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableExperimentalFeature("Observation")
            ]
        ),
        .testTarget(
            name: "OurBigKitchenTests",
            dependencies: ["OurBigKitchen"],
            path: "Tests"
        )
    ]
)
