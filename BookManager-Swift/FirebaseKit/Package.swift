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
        .package(url: "./Utility", from: "1.0.0"),
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "8.1.1")
        )
    ],
    targets: [
        .target(
            name: "FirebaseKit",
            dependencies: [
                .product(name: "Utility", package: "Utility"),
                .product(name: "FirebaseAuth", package: "Firebase"),
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase")
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
