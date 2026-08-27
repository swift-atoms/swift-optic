// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-optic",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Optic",
            targets: ["Optic"]
        ),
        .library(
            name: "Optic Standard Library Integration",
            targets: ["Optic Standard Library Integration"]
        ),
        .library(
            name: "Optic Apple Foundation Integration",
            targets: ["Optic Apple Foundation Integration"]
        ),
    ],
    targets: [
        .target(
            name: "Optic"
        ),
        .target(
            name: "Optic Standard Library Integration",
            dependencies: [
                "Optic"
            ]
        ),
        .target(
            name: "Optic Apple Foundation Integration",
            dependencies: [
                "Optic",
                "Optic Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Optic Tests",
            dependencies: [
                "Optic"
            ]
        ),
        .testTarget(
            name: "Optic Standard Library Integration Tests",
            dependencies: [
                "Optic",
                "Optic Standard Library Integration",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
