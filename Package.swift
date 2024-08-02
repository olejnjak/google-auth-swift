// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GoogleAuth",
    products: [
        .library(
            name: "GoogleAuth",
            targets: ["GoogleAuth"]
        ),
    ],
    targets: [
        .target(
            name: "GoogleAuth"
        ),
        .testTarget(
            name: "GoogleAuthTests",
            dependencies: ["GoogleAuth"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
