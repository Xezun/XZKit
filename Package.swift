// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

enum ModuleType {
    case objc;
    case swift;
    case mixed;
}

var modules: [(name: String, type: ModuleType, macros: Bool, dependencies: [PackageDescription.Target.Dependency])] = [
    // 基础
    ("XZLog",        .mixed, true,  []),
    ("XZDefines",    .objc,  false, ["XZLog"]),
    ("XZExtensions", .mixed, false, ["XZDefines"]),
    
    // 拓展
    ("XZURLQuery",       .objc,  false, []),
    ("XZGeometry",       .mixed, false, []),
    ("XZContentStatus",  .swift, false, ["XZTextImageView"]),
    ("XZImage",          .objc,  false, ["XZLog", "XZGeometry"]),
    ("XZObjcDescriptor", .objc,  false, ["XZDefines"]),
    
    // 核心
    ("XZML",      .objc,  false, ["XZDefines", "XZExtensions"]),
    ("XZMocoa",   .mixed, true,  ["XZDefines", "XZExtensions", "XZObjcDescriptor"]),
    ("XZToast",   .mixed, false, ["XZGeometry", "XZTextImageView", "XZExtensions"]),
    ("XZRefresh", .objc,  false, ["XZDefines"]),
    
    // 自定义组件
    ("XZPageView",                 .objc,  false, ["XZDefines", "XZGeometry", "XZExtensions"]),
    ("XZProgressView",             .swift, false, []),
    ("XZPageControl",              .objc,  false, ["XZExtensions"]),
    ("XZSegmentedControl",         .objc,  false, ["XZDefines"]),
    ("XZTextImageView",            .swift, false, ["XZGeometry"]),
    ("XZNavigationController",     .swift, false, ["XZDefines"]),
    ("XZCollectionViewFlowLayout", .swift, false, []),
    
    // 工具类
    ("XZTicker",         .swift, false, []),
    ("XZJSON",           .objc,  false, ["XZObjcDescriptor", "XZExtensions"]),
    ("XZLocale",         .objc,  false, ["XZDefines"]),
    ("XZDataCryptor",    .objc,  false, ["XZDefines"]),
    ("XZDataDigester",   .objc,  false, ["XZDefines", "XZExtensions"]),
    ("XZKeychain",       .objc,  false, ["XZLog"]),
]

var libraries: [Product] = []
var targets: [Target] = [
    .target(
        name: "XZKit",
        dependencies: ["XZKitObjC", "XZLogMacros", "XZMocoaMacros"],
        path: "XZKit",
        sources: ["Code/Swift"],
        swiftSettings: [.define("XZ_FRAMEWORK")]
    ),
    .target(
        name: "XZKitObjC",
        path: "XZKit",
        sources: ["Code/ObjC"],
        publicHeadersPath: "Headers/Public/XZKit",
        cSettings: [
            .headerSearchPath("Headers/Private/XZKit")
        ],
        cxxSettings: [.define("XZ_FRAMEWORK")]
    )
]

for module in modules {
    if module.macros {
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
    
    switch module.type {
    case .objc:
        targets.append(.target(
            name: module.name,
            dependencies: module.dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .swift:
        var dependencies = module.dependencies;
        if module.macros {
            dependencies.append(.init(stringLiteral: "\(module.name)Macros"))
        }
        targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    case .mixed:
        targets.append(.target(
            name: "\(module.name)ObjC",
            dependencies: module.dependencies,
            path: "XZKit",
            sources: ["Code/ObjC/\(module.name)"],
            publicHeadersPath: "Headers/Public/\(module.name)",
            cSettings: [.headerSearchPath("Headers/Private/\(module.name)")],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ))
        
        var dependencies = module.dependencies;
        dependencies.append(.byName(name: "\(module.name)ObjC"))
        
        if module.macros {
            dependencies.append(.init(stringLiteral: "\(module.name)Macros"))
        }
        
        targets.append(.target(
            name: module.name,
            dependencies: dependencies,
            path: "XZKit",
            sources: ["Code/Swift/\(module.name)"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ))
    }
    
}

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
            dependencies: ["_XZKitObjC", "XZLogMacros", "XZMocoaMacros"],
            path: "XZKit",
            sources: ["Code/Swift"],
            swiftSettings: [.define("XZ_FRAMEWORK")]
        ),
        .target(
            name: "_XZKitObjC",
            path: "XZKit",
            sources: ["Code/ObjC"],
            publicHeadersPath: "Headers/Public/XZKit",
            cSettings: [
                .headerSearchPath("Headers/Private/XZKit")
            ],
            cxxSettings: [.define("XZ_FRAMEWORK")]
        ),
        .macro(
            name: "XZLogMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "XZKit",
            sources: ["Code/Macro/XZLog"]
        ),
        .macro(
            name: "XZMocoaMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "XZKit",
            sources: ["Code/Macro/XZMocoa"]
        )
    ]
)
