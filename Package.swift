// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

private enum ModuleLang {
    case objc;
    case swift;
    case objc_swift;
}

private var modules: [(name: String, lang: ModuleLang, macros: Bool, dependencies: [PackageDescription.Target.Dependency], settings: String?)] = [
    ("XZKit",        .objc_swift, false,  ["XZLogMacros", "XZMocoaMacros"], "XZKIT_FRAMEWORK"),
    // 基础
    ("XZLog",        .objc_swift, true,  [], nil),
    ("XZDefines",    .objc,  false, ["XZLog"], nil),
    ("XZExtensions", .objc_swift, false, ["XZDefines"], nil),
    
    // 拓展
    ("XZURLQuery",       .objc,  false, [], nil),
    ("XZGeometry",       .objc_swift, false, [], nil),
    ("XZContentStatus",  .swift, false, ["XZTextImageView"], nil),
    ("XZImage",          .objc,  false, ["XZLog", "XZGeometry"], nil),
    ("XZObjcDescriptor", .objc,  false, ["XZDefines"], nil),
    
    // 核心
    ("XZML",      .objc,  false, ["XZDefines", "XZExtensions"], nil),
    ("XZMocoa",   .objc_swift, true,  ["XZDefines", "XZExtensions", "XZObjcDescriptor"], nil),
    ("XZToast",   .objc_swift, false, ["XZGeometry", "XZTextImageView", "XZExtensions"], nil),
    ("XZRefresh", .objc,  false, ["XZDefines"], nil),
    
    // 自定义组件
    ("XZPageView",                 .objc,  false, ["XZDefines", "XZGeometry", "XZExtensions"], nil),
    ("XZProgressView",             .swift, false, [], nil),
    ("XZPageControl",              .objc,  false, ["XZExtensions"], nil),
    ("XZSegmentedControl",         .objc,  false, ["XZDefines"], nil),
    ("XZTextImageView",            .swift, false, ["XZGeometry"], nil),
    ("XZNavigationController",     .swift, false, ["XZDefines"], nil),
    ("XZCollectionViewFlowLayout", .swift, false, [], nil),
    
    // 工具类
    ("XZTicker",         .swift, false, [], nil),
    ("XZJSON",           .objc,  false, ["XZObjcDescriptor", "XZExtensions"], nil),
    ("XZLocale",         .objc,  false, ["XZDefines"], nil),
    ("XZDataCryptor",    .objc,  false, ["XZDefines"], nil),
    ("XZDataDigester",   .objc,  false, ["XZDefines", "XZExtensions"], nil),
    ("XZKeychain",       .objc,  false, ["XZLog"], nil),
]
//modules.append(("XZKit", .swift, false, modules.map({ .byName(name: $0.name) })))

private var libraries: [Product] = [
//    .library(name: "XZKit", targets: ["XZKit"])
]
private var targets: [Target] = [
//    .target(
//        name: "XZKit",
//        dependencies: ["XZKitCore", "XZLogMacros", "XZMocoaMacros"],
//        path: "XZKit",
//        sources: ["Code/Swift"],
//        swiftSettings: [.define("XZ_FRAMEWORK")]
//    ),
//    .target(
//        name: "XZKitCore",
//        path: "XZKit",
//        sources: ["Code/ObjC"],
//        publicHeadersPath: "Headers/Public/XZKit",
//        cSettings: [
//            .headerSearchPath("Headers/Private/XZKit")
//        ],
//        cxxSettings: [.define("XZ_FRAMEWORK")]
//    )
];

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
    case .objc:
        targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .swift:
        targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .objc_swift:
        targets.append(.target(
            name: "\(module.name)Core",
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
        if let settings = module.settings {
            targets.append(.target(
                name: module.name,
                dependencies: [.byName(name: "\(module.name)Core")],
                path: "XZKit",
                sources: ["Code/Swift/\(module.name)"],
                swiftSettings: [
                    .define(settings),
                    .define("XZ_FRAMEWORK")]
            ))
        } else {
            targets.append(.target(
                name: module.name,
                dependencies: [.byName(name: "\(module.name)Core")],
                path: "XZKit",
                sources: ["Code/Swift/\(module.name)"],
                swiftSettings: [
                    .define("XZ_FRAMEWORK")]
            ))
        }
        
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
