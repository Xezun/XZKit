// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

// 模块

private enum ModuleLang {
    case ObjC;
    case Swift;
    case Mixed;
}

private var modules: [(name: String, lang: ModuleLang, macros: Bool, dependencies: [PackageDescription.Target.Dependency])] = [
    // 基础
    ("XZLog",        .Mixed, true, []),
    ("XZDefines",    .ObjC,  false, ["XZLog"]),
    ("XZExtensions", .Mixed, false, ["XZDefines"]),
    
    // 拓展
    ("XZURLQuery",       .ObjC,  false, []),
    ("XZGeometry",       .Mixed, false, []),
    ("XZContentStatus",  .Swift, false, ["XZTextImageView"]),
    ("XZImage",          .ObjC, false, ["XZLog", "XZGeometry"]),
    ("XZObjcDescriptor", .ObjC, false, ["XZDefines"]),
    
    // 核心
    ("XZML",      .ObjC,  false, ["XZDefines", "XZExtensions"]),
    ("XZMocoa",   .Mixed, true,  ["XZDefines", "XZExtensions", "XZObjcDescriptor"]),
    ("XZToast",   .Mixed, false, ["XZGeometry", "XZTextImageView", "XZExtensions"]),
    ("XZRefresh", .ObjC,  false, ["XZDefines"]),
    
    // 自定义组件
    ("XZPageView",                 .ObjC,  false, ["XZDefines", "XZGeometry", "XZExtensions"]),
    ("XZProgressView",             .Swift, false, []),
    ("XZPageControl",              .ObjC,  false, ["XZExtensions"]),
    ("XZSegmentedControl",         .ObjC,  false, ["XZDefines"]),
    ("XZTextImageView",            .Swift, false, ["XZGeometry"]),
    ("XZNavigationController",     .Swift, false, ["XZDefines"]),
    ("XZCollectionViewFlowLayout", .Swift, false, []),
    
    // 工具类
    ("XZTicker",         .Swift, false, []),
    ("XZJSON",           .ObjC, false,  ["XZObjcDescriptor", "XZExtensions"]),
    ("XZLocale",         .ObjC, false,  ["XZDefines"]),
    ("XZDataCryptor",    .ObjC, false,  ["XZDefines"]),
    ("XZDataDigester",   .ObjC, false,  ["XZDefines", "XZExtensions"]),
    ("XZKeychain",       .ObjC, false,  ["XZLog"]),
]
modules.append(("XZKit", .Swift, false, modules.map({ .byName(name: $0.name) })))

private var libraries = [Product]();
private var targets = [Target]();

for module in modules {
    libraries.append(.library(name: module.name, targets: [module.name]))
    
    var dependencies = module.dependencies;
    
    if module.macros {
        dependencies.append(.init(stringLiteral: "\(module.name)Macros"))
        targets.append(
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
    
    switch module.lang {
    case .ObjC:
        targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .Swift:
        targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .Mixed:
        targets.append(.target(
            name: "\(module.name)Core",
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
        targets.append(.target(
            name: module.name,
            dependencies: [.byName(name: "\(module.name)Core")],
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    }
    
}

// 单元测试

targets.append(
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
    products: libraries,
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: targets
)
