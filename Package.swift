// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XZKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "XZKit",
            targets: ["XZKit"]),
        .library(
            name: "XZDefines",
            targets: ["XZDefines"]),
        .library(
            name: "XZExtensions",
            targets: ["XZExtensions"]),
        .library(
            name: "XZMocoa",
            targets: ["XZMocoa"]),
        .library(
            name: "XZML",
            targets: ["XZML"]),
        .library(
            name: "XZJSON",
            targets: ["XZJSON"]),
        .library(
            name: "XZRefresh",
            targets: ["XZRefresh"]),
        .library(
            name: "XZPageView",
            targets: ["XZPageView"]),
        .library(
            name: "XZPageControl",
            targets: ["XZPageControl"]),
        .library(
            name: "XZSegmentedControl",
            targets: ["XZSegmentedControl"]),
        .library(
            name: "XZGeometry",
            targets: ["XZGeometry"]),
        .library(
            name: "XZContentStatus",
            targets: ["XZContentStatus"]),
        .library(
            name: "XZTextImageView",
            targets: ["XZTextImageView"]),
        .library(
            name: "XZToast",
            targets: ["XZToast"]),
        .library(
            name: "XZURLQuery",
            targets: ["XZURLQuery"]),
        .library(
            name: "XZLocale",
            targets: ["XZLocale"]),
        .library(
            name: "XZCollectionViewFlowLayout",
            targets: ["XZCollectionViewFlowLayout"]),
        .library(
            name: "XZNavigationController",
            targets: ["XZNavigationController"]),
        .library(
            name: "XZDataCryptor",
            targets: ["XZDataCryptor"]),
        .library(
            name: "XZDataDigester",
            targets: ["XZDataDigester"]),
        .library(
            name: "XZKeychain",
            targets: ["XZKeychain"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XZKit",
            dependencies: [
                "XZDefines", 
                "XZExtensions",
                "XZCollectionViewFlowLayout",
                "XZContentStatus",
                "XZDataCryptor",
                "XZDataDigester",
                "XZGeometry",
                "XZJSON",
                "XZKeychain",
                "XZLocale",
                "XZML",
                "XZMocoa",
                "XZNavigationController",
                "XZPageControl",
                "XZPageView",
                "XZRefresh",
                "XZSegmentedControl",
                "XZTextImageView",
                "XZToast",
                "XZURLQuery",
            ],
            path: "XZKit",
            sources: ["Code/Swift/XZKit"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ],
            swiftSettings: [
                .define("XZKIT_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZDefines",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/ObjC/XZDefines"],
            publicHeadersPath: "Headers/Public/XZDefines",
            cSettings: [
                .headerSearchPath("Headers/Private/XZDefines")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZExtensions",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/ObjC/XZExtensions"],
            publicHeadersPath: "Headers/Public/XZExtensions",
            cSettings: [
                .headerSearchPath("Headers/Private/XZExtensions")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZMocoaObjC",
            dependencies: ["XZDefines", "XZExtensions"],
            path: "XZKit",
            sources: ["Code/ObjC/XZMocoa"],
            publicHeadersPath: "Headers/Public/XZMocoa",
            cSettings: [
                .headerSearchPath("Headers/Private/XZMocoa")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZMocoa",
            dependencies: ["XZMocoaObjC"],
            path: "XZKit",
            sources: ["Code/Swift/XZMocoa"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZML",
            dependencies: ["XZDefines", "XZExtensions"],
            path: "XZKit",
            sources: ["Code/ObjC/XZML"],
            publicHeadersPath: "Headers/Public/XZML",
            cSettings: [
                .headerSearchPath("Headers/Private/XZML")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZJSON",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/ObjC/XZJSON"],
            publicHeadersPath: "Headers/Public/XZJSON",
            cSettings: [
                .headerSearchPath("Headers/Private/XZJSON")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZRefresh",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/ObjC/XZRefresh"],
            publicHeadersPath: "Headers/Public/XZRefresh",
            cSettings: [
                .headerSearchPath("Headers/Private/XZRefresh")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZPageView",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/ObjC/XZPageView"],
            publicHeadersPath: "Headers/Public/XZPageView",
            cSettings: [
                .headerSearchPath("Headers/Private/XZPageView")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZPageControl",
            dependencies: ["XZExtensions"],
            path: "XZKit",
            sources: ["Code/ObjC/XZPageControl"],
            publicHeadersPath: "Headers/Public/XZPageControl",
            cSettings: [
                .headerSearchPath("Headers/Private/XZPageControl")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZSegmentedControl",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/ObjC/XZSegmentedControl"],
            publicHeadersPath: "Headers/Public/XZSegmentedControl",
            cSettings: [
                .headerSearchPath("Headers/Private/XZSegmentedControl")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZGeometry",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/Swift/XZGeometry"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZContentStatus",
            dependencies: ["XZTextImageView"],
            path: "XZKit",
            sources: ["Code/Swift/XZContentStatus"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZTextImageView",
            dependencies: ["XZGeometry"],
            path: "XZKit",
            sources: ["Code/Swift/XZTextImageView"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZToast",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/Swift/XZToast"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZURLQuery",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/ObjC/XZURLQuery"],
            publicHeadersPath: "Headers/Public/XZURLQuery",
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZLocale",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/ObjC/XZLocale"],
            publicHeadersPath: "Headers/Public/XZLocale",
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZCollectionViewFlowLayout",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/Swift/XZCollectionViewFlowLayout"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZNavigationController",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/Swift/XZNavigationController"],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZDataCryptor",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/ObjC/XZDataCryptor"],
            publicHeadersPath: "Headers/Public/XZDataCryptor",
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZDataDigester",
            dependencies: ["XZDefines", "XZExtensions"],
            path: "XZKit",
            sources: ["Code/ObjC/XZDataDigester"],
            publicHeadersPath: "Headers/Public/XZDataDigester",
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZKeychain",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/ObjC/XZKeychain"],
            publicHeadersPath: "Headers/Public/XZKeychain",
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        )
    ]
)
