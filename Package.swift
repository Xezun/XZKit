// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

// 模块

private enum ModuleType {
    case ObjC;
    case Swift;
    case Mixed;
}

private var _modules: [(type: ModuleType, name: String, dependencies: [PackageDescription.Target.Dependency])] = [
    (.ObjC, "XZML", ["XZDefines", "XZExtensions"]),
    (.ObjC, "XZJSON", ["XZObjcDescriptor", "XZExtensions"]),
    (.ObjC, "XZRefresh", ["XZDefines"]),
    (.ObjC, "XZPageView", ["XZDefines", "XZGeometry", "XZExtensions"]),
    (.ObjC, "XZPageControl", ["XZExtensions"]),
    (.ObjC, "XZSegmentedControl", ["XZDefines"]),
    (.ObjC, "XZURLQuery", []),
    (.ObjC, "XZLocale", ["XZDefines"]),
    (.ObjC, "XZDataCryptor", ["XZDefines"]),
    (.ObjC, "XZDataDigester", ["XZDefines", "XZExtensions"]),
    (.ObjC, "XZKeychain", []),
    (.ObjC, "XZImage", ["XZGeometry"]),
    (.ObjC, "XZObjcDescriptor", ["XZDefines"]),
    (.Swift, "XZTextImageView", ["XZGeometry"]),
    (.Swift, "XZContentStatus", ["XZTextImageView"]),
    (.Swift, "XZCollectionViewFlowLayout", []),
    (.Swift, "XZProgressView", []),
    (.Swift, "XZTicker", []),
    (.Swift, "XZNavigationController", ["XZDefines"]),
    (.Mixed, "XZDefines", ["XZDefinesMacros"]),
    (.Mixed, "XZExtensions", ["XZDefines"]),
    (.Mixed, "XZGeometry", []),
    (.Mixed, "XZToast", ["XZGeometry", "XZTextImageView", "XZExtensions"]),
    (.Mixed, "XZMocoa", ["XZDefines", "XZExtensions", "XZObjcDescriptor", "XZMocoaMacros"]),
]
_modules.append((.Swift, "XZKit", _modules.map({ .byName(name: $0.name) })))

private var _products = [Product]();
private var _targets = [Target]();

for module in _modules {
    _products.append(.library(name: module.name, targets: [module.name]))
    switch module.type {
    case .ObjC:
        _targets.append(.target(
            name: module.name,
            dependencies: module.dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .Swift:
        _targets.append(.target(
            name: module.name,
            dependencies: module.dependencies,
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .Mixed:
        _targets.append(.target(
            name: "\(module.name)ObjC",
            dependencies: module.dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
        _targets.append(.target(
            name: module.name,
            dependencies: [.byName(name: "\(module.name)ObjC")],
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    }
}

// 宏

_targets.append(
    .macro(
        name: "XZMocoaMacros",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ],
        path: "XZKit",
        sources: ["Code/Macro/XZMocoa"]
    )
)

_targets.append(
    .macro(
        name: "XZDefinesMacros",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ],
        path: "XZKit",
        sources: ["Code/Macro/XZDefines"]
    )
)

// 应用

_targets.append(
    .executableTarget(
        name: "Example",
        dependencies: ["XZKit"],
        path: "XZKit",
        sources: ["Code/Swift/Example"]
    )
)
_products.append(
    .executable(name: "Example", targets: ["Example"])
)

// 单元测试

_targets.append(
    .testTarget(
        name: "XZMocoaMacrosTests",
        dependencies: [
            "XZMocoaMacros",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ],
        path: "Tests",
        sources: ["Macro/XZMocoa"]
    )
)


let package = Package(
    name: "XZKit",
    platforms: [.iOS(.v13), .macOS(.v15)],
    products: _products,
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: _targets
)
