// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private enum ModuleType {
    case ObjC;
    case Swift;
    case Mixed;
}

private var _modules: [(type: ModuleType, name: String, dependencies: [PackageDescription.Target.Dependency])] = [
    (.ObjC, "XZDefines", []),
    (.ObjC, "XZExtensions", ["XZDefines"]),
    (.ObjC, "XZML", ["XZDefines", "XZExtensions"]),
    (.ObjC, "XZJSON", ["XZObjcDescriptor", "XZExtensions"]),
    (.ObjC, "XZRefresh", ["XZDefines"]),
    (.ObjC, "XZPageView", ["XZDefines"]),
    (.ObjC, "XZPageControl", ["XZExtensions"]),
    (.ObjC, "XZSegmentedControl", ["XZDefines"]),
    (.ObjC, "XZURLQuery", []),
    (.ObjC, "XZLocale", ["XZDefines"]),
    (.ObjC, "XZDataCryptor", ["XZDefines"]),
    (.ObjC, "XZDataDigester", ["XZDefines", "XZExtensions"]),
    (.ObjC, "XZKeychain", []),
    (.Swift, "XZGeometry", []),
    (.Swift, "XZTextImageView", ["XZGeometry"]),
    (.Swift, "XZContentStatus", ["XZTextImageView"]),
    (.Swift, "XZCollectionViewFlowLayout", []),
    (.Swift, "XZNavigationController", ["XZDefines"]),
    (.Mixed, "XZToast", []),
    (.Mixed, "XZMocoa", ["XZDefines", "XZExtensions"]),
    (.Mixed, "XZObjcDescriptor", ["XZDefines"]),
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

let package = Package(name: "XZKit", platforms: [.iOS(.v12)], products: _products, dependencies: [], targets: _targets)
