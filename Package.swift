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
        .library(name: "Optic", targets: ["Optic"]),

        .library(name: "Optic Foundation Integration", targets: ["Optic Foundation Integration"]),
        .library(name: "Optic Test Support", targets: ["Optic Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "Optic",
            dependencies: [
                .product(name: "Either", package: "swift-either"),
            ],
            path: "Sources/Optic"
        ),
        
        .target(
            name: "Optic Foundation Integration",
            dependencies: [
                .target(name: "Optic"),
            ],
            path: "Sources/Optic Foundation Integration"
        ),
        .target(
            name: "Optic Test Support",
            dependencies: [
                .target(name: "Optic"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Optic Tests",
            dependencies: [
                .target(name: "Optic"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "Optic Test Support"),
                .target(name: "Optic Foundation Integration"),
            ],
            path: "Tests/Optic Tests",
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("MoveOnlyTuples"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
