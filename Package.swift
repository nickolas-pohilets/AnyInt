// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnyInt",
    platforms: [
       .macOS("13.3"),
       .iOS("16.4"),
       .watchOS("9.4"),
       .tvOS("16.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AnyInt",
            targets: ["AnyInt"]
        ),
        .plugin(
            name: "CopyFiles",
            targets: [
                "CopyFiles"
            ]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "AnyInt"),
        .testTarget(
            name: "AnyIntTests",
            dependencies: [
                "AnyInt"
            ]
        ),
        .target(
            name: "AnyInt_MicroWord",
            swiftSettings: [
                .define("MICRO_WORD")
            ],
            plugins: [
                .plugin(name: "CopyFiles"),
            ]
        ),
        .testTarget(
            name: "AnyIntFuzzingTests",
            dependencies: [
                "AnyInt_MicroWord"
            ]
        ),
        .plugin(
            name: "CopyFiles",
            capability: .buildTool()
        )
    ]
)
