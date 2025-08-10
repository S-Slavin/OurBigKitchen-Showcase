// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OurBigKitchen",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "OurBigKitchen",
            targets: ["OurBigKitchen"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OurBigKitchen",
            path: "OurBigKitchen",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
