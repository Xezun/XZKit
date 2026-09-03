// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "XZKit",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        .library(name: "XZKit", targets: ["XZKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        .target(
            name: "XZKit",
            dependencies: ["XZKitObjC", "XZKitMacros"],
            path: "Sources",
            exclude: ["ObjC", "Macro", "Header"],
            sources: ["Swift"],
            swiftSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZKitObjC",
            dependencies: [],
            path: "Sources",
            exclude: ["Swift", "Macro", "Header"],
            sources: ["ObjC"],
            publicHeadersPath: "Header/XZKit/Public",
            cSettings: [
                .headerSearchPath("Header/XZKit/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .macro(
            name: "XZKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/Macro"
        ),
        .testTarget(
            name: "MacroTests",
            dependencies: [
                "XZKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests/Macro"
        ),
        .testTarget(
            name: "XZMocoaModuleTests",
            dependencies: ["XZKit"],
            path: "Tests/XZMocoa"
        ),
        .executableTarget(
            name: "Demo",
            dependencies: ["XZKit"],
            path: "Projects/Demo"
        )
    ]
)
