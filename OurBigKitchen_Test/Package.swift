// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OurBigKitchen",
    platforms: [.iOS(.v14)],
    products: [
        .executable(name: "OurBigKitchen", targets: ["OurBigKitchen"])
    ],
    targets: [
        .target(
            name: "OurBigKitchen",
            path: "OurBigKitchen"
        ),
        .testTarget(
            name: "OurBigKitchenTests",
            dependencies: ["OurBigKitchen"],
            path: "OurBigKitchenTests"
        )
    ]
)
