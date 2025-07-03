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

private var _modules: [(type: ModuleType, macros: Bool, name: String, dependencies: [PackageDescription.Target.Dependency])] = [
    (.Mixed, true, "XZLog", []),
    (.ObjC, false, "XZML", ["XZDefines", "XZExtensions"]),
    (.ObjC, false, "XZJSON", ["XZObjcDescriptor", "XZExtensions"]),
    (.ObjC, false, "XZRefresh", ["XZDefines"]),
    (.ObjC, false, "XZPageView", ["XZDefines", "XZGeometry", "XZExtensions"]),
    (.ObjC, false, "XZPageControl", ["XZExtensions"]),
    (.ObjC, false, "XZSegmentedControl", ["XZDefines"]),
    (.ObjC, false, "XZURLQuery", []),
    (.ObjC, false, "XZLocale", ["XZDefines"]),
    (.ObjC, false, "XZDataCryptor", ["XZDefines"]),
    (.ObjC, false, "XZDataDigester", ["XZDefines", "XZExtensions"]),
    (.ObjC, false, "XZKeychain", ["XZLog"]),
    (.ObjC, false, "XZImage", ["XZLog", "XZGeometry"]),
    (.ObjC, false, "XZObjcDescriptor", ["XZDefines"]),
    (.Swift, false, "XZTextImageView", ["XZGeometry"]),
    (.Swift, false, "XZContentStatus", ["XZTextImageView"]),
    (.Swift, false, "XZCollectionViewFlowLayout", []),
    (.Swift, false, "XZProgressView", []),
    (.Swift, false, "XZTicker", []),
    (.Swift, false, "XZNavigationController", ["XZDefines"]),
    (.ObjC, false, "XZDefines", ["XZLog"]),
    (.Mixed, false, "XZExtensions", ["XZDefines"]),
    (.Mixed, false, "XZGeometry", []),
    (.Mixed, false, "XZToast", ["XZGeometry", "XZTextImageView", "XZExtensions"]),
    (.Mixed, true, "XZMocoa", ["XZDefines", "XZExtensions", "XZObjcDescriptor"]),
]
_modules.append((.Swift, false, "XZKit", _modules.map({ .byName(name: $0.name) })))

private var _products = [Product]();
private var _targets = [Target]();

for module in _modules {
    _products.append(.library(name: module.name, targets: [module.name]))
    
    var dependencies = module.dependencies;
    
    if module.macros {
        dependencies.append(.init(stringLiteral: "\(module.name)Macros"))
        _targets.append(
            .macro(
                name: "\(module.name)Macros",
                dependencies: [
                    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                    .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
                ],
                path: "XZKit",
                sources: ["Code/Macro/\(module.name)"]
            )
        )
    }
    
    switch module.type {
    case .ObjC:
        _targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .Swift:
        _targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .Mixed:
        _targets.append(.target(
            name: "\(module.name)Core",
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
        _targets.append(.target(
            name: module.name,
            dependencies: [.byName(name: "\(module.name)Core")],
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    }
    
}

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
