// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FirebaseKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "FirebaseKit",
            targets: [
                "FirebaseKit"
            ]
        )
    ],
    dependencies: [
        .package(url: "./Utility", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "FirebaseKit",
            dependencies: [
                .product(name: "Utility", package: "Utility")
            ]
        ),
        .testTarget(
            name: "FirebaseKitTests",
            dependencies: [
                "FirebaseKit"
            ]
        )
    ]
)
