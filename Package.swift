// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swiftmapper",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Swiftmapper",
            targets: ["Swiftmapper"],
        ),
        .library(
            name: "Libmapper", 
            targets: ["libmapper"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Swiftmapper",
            dependencies: ["libmapper"],
        ),
        .executableTarget(name: "Demo", dependencies: ["Swiftmapper"]),
        .systemLibrary(
            name: "libmapper",
            pkgConfig: "libmapper",
            providers: [
                .brew(["libmapper"])
            ]
        ),
        .testTarget(
            name: "SwiftmapperTests",
            dependencies: ["Swiftmapper"]
        ),
    ]
)
