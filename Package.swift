// swift-tools-version:5.3
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
            targets: ["XZSegmentedControl"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XZDefines",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/XZDefines"],
            publicHeadersPath: "Headers/XZDefines/Public",
            cSettings: [
                .headerSearchPath("Headers/XZDefines/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZExtensions",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/XZExtensions"],
            publicHeadersPath: "Headers/XZExtensions/Public",
            cSettings: [
                .headerSearchPath("Headers/XZExtensions/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZMocoa",
            dependencies: ["XZDefines", "XZExtensions"],
            path: "XZKit",
            sources: ["Code/XZMocoa"],
            publicHeadersPath: "Headers/XZMocoa/Public",
            cSettings: [
                .headerSearchPath("Headers/XZMocoa/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZML",
            dependencies: ["XZDefines", "XZExtensions"],
            path: "XZKit",
            sources: ["Code/XZML"],
            publicHeadersPath: "Headers/XZML/Public",
            cSettings: [
                .headerSearchPath("Headers/XZML/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZJSON",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/XZJSON"],
            publicHeadersPath: "Headers/XZJSON/Public",
            cSettings: [
                .headerSearchPath("Headers/XZJSON/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZRefresh",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/XZRefresh"],
            publicHeadersPath: "Headers/XZRefresh/Public",
            cSettings: [
                .headerSearchPath("Headers/XZRefresh/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZPageView",
            dependencies: ["XZDefines"],
            path: "XZKit",
            sources: ["Code/XZPageView"],
            publicHeadersPath: "Headers/XZPageView/Public",
            cSettings: [
                .headerSearchPath("Headers/XZPageView/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZPageControl",
            dependencies: ["XZExtensions"],
            path: "XZKit",
            sources: ["Code/XZPageControl"],
            publicHeadersPath: "Headers/XZPageControl/Public",
            cSettings: [
                .headerSearchPath("Headers/XZPageControl/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        ),
        .target(
            name: "XZSegmentedControl",
            dependencies: [],
            path: "XZKit",
            sources: ["Code/XZSegmentedControl"],
            publicHeadersPath: "Headers/XZSegmentedControl/Public",
            cSettings: [
                .headerSearchPath("Headers/XZSegmentedControl/Private")
            ],
            cxxSettings: [
                .define("XZ_FRAMEWORK")
            ]
        )
    ]
)
