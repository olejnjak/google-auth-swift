// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GoogleAuth",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "GoogleAuth",
            targets: ["GoogleAuth"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/vapor/jwt-kit",
            from: "5.1.0"
        ),
    ],
    targets: [
        .target(
            name: "GoogleAuth",
            dependencies: [
                .product(name: "JWTKit", package: "jwt-kit")
            ]
        ),
        .testTarget(
            name: "GoogleAuthTests",
            dependencies: ["GoogleAuth"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
