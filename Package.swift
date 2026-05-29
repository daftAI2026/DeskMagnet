// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DeskMagnet",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "DeskMagnetCore", targets: ["DeskMagnetCore"]),
        .executable(name: "deskmagnet", targets: ["DeskMagnetCLI"])
    ],
    targets: [
        .target(name: "DeskMagnetCore", exclude: ["CLAUDE.md"]),
        .executableTarget(
            name: "DeskMagnetCLI",
            dependencies: ["DeskMagnetCore"],
            exclude: ["CLAUDE.md"]
        ),
        .testTarget(
            name: "DeskMagnetCoreTests",
            dependencies: ["DeskMagnetCore"],
            exclude: ["CLAUDE.md"]
        )
    ]
)
