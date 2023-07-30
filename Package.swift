// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PromiseKit",
    products: [
        .library(
            name: "PromiseKit",
            targets: ["PromiseKit", "PMKExtensions", "PMKExtensionsObjc"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PromiseKit",
            path: "Sources/PromiseKit/PromiseKit.xcframework"
        ),
        .target(
            name: "PMKExtensions",
            dependencies: ["PromiseKit"]
        ),
        .target(
            name: "PMKExtensionsObjc",
            dependencies: ["PromiseKit"]
        ),
        .testTarget(
            name: "PromiseKitTests",
            dependencies: ["PromiseKit"]
        ),
    ]
)
