// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PromiseKit",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PromiseKit",
            targets: ["PromiseKit", "PMKExtensions", "PMKExtensionsObjc"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "PromiseKit",
            path: "Sources/PromiseKit/PromiseKit.xcframework"
        ),
        .target(
            name: "PMKExtensions",
            dependencies: ["PromiseKit"],
            path: "Sources/PMKExtensions"
        ),
        .target(
            name: "PMKExtensionsObjc",
            dependencies: ["PromiseKit"],
            path: "Sources/PMKExtensionsObjc"
        ),
        .testTarget(
            name: "PromiseKitTests",
            dependencies: ["PromiseKit"]),
    ]
)
