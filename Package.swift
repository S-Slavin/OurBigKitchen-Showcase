// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OurBigKitchen",
    platforms: [.iOS(.v14)],
    products: [
        .executable(
            name: "OurBigKitchen",
            targets: ["OurBigKitchen"]
        )
    ],
    dependencies: [
        // Add Salesforce SDK dependency here when ready
        // .package(url: "https://github.com/forcedotcom/SalesforceMobileSDK-iOS.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "OurBigKitchen",
            dependencies: [
                // Add Salesforce SDK target here when ready
                // "SalesforceMobileSDK"
            ],
            path: "OurBigKitchen_Restored/OurBigKitchen",
            resources: [
                .process("Info.plist"),
                .process("GoogleService-Info.plist"),
                .process("OurBigKitchen.entitlements")
            ]
        )
    ]
)
