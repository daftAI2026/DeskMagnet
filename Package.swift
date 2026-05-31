// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DeskMagnet",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "DeskMagnetCore", targets: ["DeskMagnetCore"]),
        .executable(name: "deskmagnet", targets: ["DeskMagnetCLI"]),
        .executable(name: "DeskMagnetApp", targets: ["DeskMagnetApp"])
    ],
    targets: [
        .target(
            name: "DeskMagnetCore",
            exclude: [
                "CLAUDE.md",
                "Automation/CLAUDE.md",
                "Coordination/CLAUDE.md",
                "State/CLAUDE.md"
            ]
        ),
        .executableTarget(
            name: "DeskMagnetCLI",
            dependencies: ["DeskMagnetCore"],
            exclude: ["CLAUDE.md"]
        ),
        .executableTarget(
            name: "DeskMagnetApp",
            dependencies: ["DeskMagnetCore"],
            exclude: ["CLAUDE.md"]
        ),
        .testTarget(
            name: "DeskMagnetCoreTests",
            dependencies: ["DeskMagnetCore"],
            exclude: ["CLAUDE.md"]
        ),
        .testTarget(
            name: "DeskMagnetAppTests",
            dependencies: ["DeskMagnetApp"],
            exclude: ["CLAUDE.md"]
        )
    ]
)
