// swift-tools-version: 6.4

import CompilerPluginSupport
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
        .library(name: "Optic Algebra Integration", targets: ["Optic Algebra Integration"]),
        .library(name: "Optic", targets: ["Optic"]),

        .library(name: "Optic Foundation Integration", targets: ["Optic Foundation Integration"]),
        .library(name: "Optic Test Support", targets: ["Optic Test Support"]),
        .library(name: "Case Macro", targets: ["Case Macro"]),
        .library(name: "Fold Macro", targets: ["Fold Macro"]),
        .library(name: "Isomorphism Macro", targets: ["Isomorphism Macro"]),
        .library(name: "Lens Macro", targets: ["Lens Macro"]),
        .library(name: "Prism Macro", targets: ["Prism Macro"]),
        .library(name: "Traversal Macro", targets: ["Traversal Macro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-bifunctor.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-algebra.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-product.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "603.0.2"..<"604.0.0"),
        .package(url: "https://github.com/swift-atoms/swift-coproduct.git", branch: "main"),
    ],
    targets: [
        .testTarget(name: "Optic Algebra Integration Tests", dependencies: [
            "Optic Algebra Integration",
            "Lens Macro",
            "Isomorphism Macro",
            "Prism Macro",
            .product(name: "Algebra Test Support", package: "swift-algebra"),
        ]),
        .target(name: "Optic Algebra Integration", dependencies: [
            "Optic",
            .product(name: "Algebra", package: "swift-algebra"),
            .product(name: "Bifunctor", package: "swift-bifunctor"),
        ]),
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
        .target(
            name: "Case Macro Core",
            dependencies: [
                .product(name: "Coproduct Syntax", package: "swift-coproduct"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "Case Macro Plugin",
            dependencies: [
                "Case Macro Core",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Case Macro",
            dependencies: [
                "Case Macro Plugin",
                "Fold Macro",
                "Optic",
                "Prism Macro",
            ]
        ),
        .testTarget(
            name: "Case Macro Tests",
            dependencies: [
                "Case Macro",
                "Case Macro Plugin",
                "Fold Macro Plugin",
                "Prism Macro Plugin",
            ]
        ),
        .target(
            name: "Fold Macro Core",
            dependencies: [
                .product(name: "Coproduct Syntax", package: "swift-coproduct"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "Fold Macro Plugin",
            dependencies: [
                "Fold Macro Core",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Fold Macro",
            dependencies: [
                "Fold Macro Plugin",
                "Optic",
            ]
        ),
        .testTarget(
            name: "Fold Macro Tests",
            dependencies: [
                "Fold Macro",
                "Fold Macro Plugin",
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Isomorphism Macro Core",
            dependencies: [
                .product(name: "Type Algebra Syntax", package: "swift-algebra"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "Isomorphism Macro Plugin",
            dependencies: [
                "Isomorphism Macro Core",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Isomorphism Macro",
            dependencies: [
                "Isomorphism Macro Plugin",
                "Optic",
            ]
        ),
        .testTarget(
            name: "Isomorphism Macro Tests",
            dependencies: [
                "Isomorphism Macro",
                "Isomorphism Macro Plugin",
                "Optic",
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Lens Macro Core",
            dependencies: [
                .product(name: "Type Algebra Syntax", package: "swift-algebra"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "Lens Macro Plugin",
            dependencies: [
                "Lens Macro Core",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Lens Macro",
            dependencies: [
                "Lens Macro Plugin",
                "Optic",
            ]
        ),
        .testTarget(
            name: "Lens Macro Tests",
            dependencies: [
                "Lens Macro",
                "Lens Macro Plugin",
                "Optic",
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Prism Macro Core",
            dependencies: [
                .product(name: "Coproduct Syntax", package: "swift-coproduct"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "Prism Macro Plugin",
            dependencies: [
                "Prism Macro Core",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Prism Macro",
            dependencies: [
                "Prism Macro Plugin",
                .product(name: "Either", package: "swift-either"),
                "Optic",
            ]
        ),
        .testTarget(
            name: "Prism Macro Tests",
            dependencies: [
                "Prism Macro",
                "Prism Macro Plugin",
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ],
            resources: [.copy("Fixtures")]
        ),
        .target(
            name: "Traversal Macro Core",
            dependencies: [
                .product(name: "Type Algebra Syntax", package: "swift-algebra"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "Traversal Macro Plugin",
            dependencies: [
                "Traversal Macro Core",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Traversal Macro",
            dependencies: [
                "Lens Macro",
                "Traversal Macro Plugin",
                "Optic",
            ]
        ),
        .testTarget(
            name: "Traversal Macro Tests",
            dependencies: [
                "Traversal Macro",
                "Optic",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
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

// Consumer compilation must reject visibility regressions, even when other packages suppress warnings.
for target in package.targets where target.type == .test || target.name.hasSuffix("Consumer Fixtures") {
    target.swiftSettings = (target.swiftSettings ?? []) + [.treatAllWarnings(as: .error)]
}
