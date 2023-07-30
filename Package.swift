// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PromiseKit",
    platforms: [.iOS(.v11)], // The XCFramework bundle (built from the origin PromiseKit) is manually built for specific platforms. Setting this `platforms` value assures that this package is only available to platforms supported by the bundle.
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
