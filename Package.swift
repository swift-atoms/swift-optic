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
        .testTarget(
            name: "Optic Algebra Integration Tests",
            dependencies: [
                .target(name: "Optic Algebra Integration"),
                .target(name: "Lens Macro"),
                .target(name: "Isomorphism Macro"),
                .target(name: "Prism Macro"),
                .product(name: "Algebra Test Support", package: "swift-algebra"),
            ]
        ),
        .target(
            name: "Optic Algebra Integration",
            dependencies: [
                .target(name: "Optic"),
                .product(name: "Algebra", package: "swift-algebra"),
                .product(name: "Bifunctor", package: "swift-bifunctor"),
            ]
        ),
        .target(
            name: "Optic",
            dependencies: [
                .product(name: "Either", package: "swift-either")
            ],
            path: "Sources/Optic",
            swiftSettings: [.enableExperimentalFeature("MoveOnlyTuples")]
        ),

        .target(
            name: "Optic Foundation Integration",
            dependencies: [
                .target(name: "Optic")
            ],
            path: "Sources/Optic Foundation Integration"
        ),
        .target(
            name: "Optic Test Support",
            dependencies: [
                .target(name: "Optic")
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Optic Tests",
            dependencies: [
                .target(name: "Optic"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "Optic Test Support"),
            ],
            path: "Tests/Optic Tests",
            resources: [.copy("Fixtures")],
            swiftSettings: [.enableExperimentalFeature("MoveOnlyTuples")]
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
                .target(name: "Case Macro Core"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Case Macro",
            dependencies: [
                .target(name: "Case Macro Plugin"),
                .target(name: "Fold Macro"),
                .target(name: "Optic"),
                .target(name: "Prism Macro"),
            ]
        ),
        .testTarget(
            name: "Case Macro Tests",
            dependencies: [
                .target(name: "Case Macro"),
                .target(name: "Case Macro Plugin"),
                .target(name: "Fold Macro Plugin"),
                .target(name: "Prism Macro Plugin"),
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
                .target(name: "Fold Macro Core"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Fold Macro",
            dependencies: [
                .target(name: "Fold Macro Plugin"),
                .target(name: "Optic"),
            ]
        ),
        .testTarget(
            name: "Fold Macro Tests",
            dependencies: [
                .target(name: "Fold Macro"),
                .target(name: "Fold Macro Plugin"),
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
                .target(name: "Isomorphism Macro Core"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Isomorphism Macro",
            dependencies: [
                .target(name: "Isomorphism Macro Plugin"),
                .target(name: "Optic"),
            ]
        ),
        .testTarget(
            name: "Isomorphism Macro Tests",
            dependencies: [
                .target(name: "Isomorphism Macro"),
                .target(name: "Isomorphism Macro Plugin"),
                .target(name: "Optic"),
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
                .target(name: "Lens Macro Core"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Lens Macro",
            dependencies: [
                .target(name: "Lens Macro Plugin"),
                .target(name: "Optic"),
            ]
        ),
        .testTarget(
            name: "Lens Macro Tests",
            dependencies: [
                .target(name: "Lens Macro"),
                .target(name: "Lens Macro Plugin"),
                .target(name: "Optic"),
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
                .target(name: "Prism Macro Core"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Prism Macro",
            dependencies: [
                .target(name: "Prism Macro Plugin"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "Optic"),
            ]
        ),
        .testTarget(
            name: "Prism Macro Tests",
            dependencies: [
                .target(name: "Prism Macro"),
                .target(name: "Prism Macro Plugin"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ],
            resources: [.copy("Fixtures")],
            swiftSettings: [.enableExperimentalFeature("MoveOnlyTuples")]
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
                .target(name: "Traversal Macro Core"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Traversal Macro",
            dependencies: [
                .target(name: "Lens Macro"),
                .target(name: "Traversal Macro Plugin"),
                .target(name: "Optic"),
            ]
        ),
        .testTarget(
            name: "Traversal Macro Tests",
            dependencies: [
                .target(name: "Traversal Macro"),
                .target(name: "Optic"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
