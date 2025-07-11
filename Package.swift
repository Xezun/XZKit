// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "XZKit",
    platforms: [.iOS(.v13), .macOS(.v15)],
    products: [
        .library(name: "XZKit", targets: ["XZKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        .target(
            name: "XZKit",
            dependencies: ["_XZKitObjC", "XZKitMacros"],
            path: "Sources",
            sources: ["Code/Swift"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ),
        .target(
            name: "_XZKitObjC",
            path: "Sources",
            sources: ["Code/ObjC"],
            publicHeadersPath: "Headers/Public/XZKit",
            cSettings: [
                .headerSearchPath("Headers/Private/XZKit")
            ],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ),
        .macro(
            name: "XZKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources",
            sources: ["Code/Macro"]
        )
    ]
)
