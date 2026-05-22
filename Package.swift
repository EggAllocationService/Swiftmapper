// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swiftmapper",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Swiftmapper",
            targets: ["Swiftmapper"]
        ),
        .library(
            name: "Libmapper",
            targets: ["libmapper"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "Swiftmapper",
            dependencies: ["libmapper"]
        ),
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
        )
    ]
)
