// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "XZKit",
    platforms: [.iOS(.v13), .macOS(.v13)],
    products: [
        .library(name: "XZKit", targets: ["XZKit"]),
        .executable(
            name: "Demo",
            targets: ["Demo"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        .target(
            name: "XZKit",
            dependencies: ["XZKitObjC", "XZKitMacros"],
            path: "Sources/Swift",
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ),
        .target(
            name: "XZKitObjC",
            path: "Sources/ObjC",
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
            path: "Sources/Macro"
        ),
        .testTarget(
            name: "MacroTests",
            dependencies: [
                "XZKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests"
        ),
        .executableTarget(
            name: "Demo",
            dependencies: ["XZKit"],
            path: "Projects/Demo"
        ),
    ]
)
