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
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "604.0.0"..<"605.0.0"),
        .package(url: "https://github.com/swift-atoms/swift-coproduct.git", branch: "main"),
    ],
    traits: [
        .trait(name: "CaseMacro", description: "Case Macro and the dependencies only it needs"),
        .trait(name: "FoldMacro", description: "Fold Macro and the dependencies only it needs"),
        .trait(name: "IsomorphismMacro", description: "Isomorphism Macro and the dependencies only it needs"),
        .trait(name: "LensMacro", description: "Lens Macro and the dependencies only it needs"),
        .trait(name: "OpticAlgebraIntegration", description: "Optic Algebra Integration and the dependencies only it needs"),
        .trait(name: "PrismMacro", description: "Prism Macro and the dependencies only it needs"),
        .trait(name: "TraversalMacro", description: "Traversal Macro and the dependencies only it needs"),
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
                .product(name: "Algebra", package: "swift-algebra", condition: .when(traits: ["OpticAlgebraIntegration"])),
                .product(name: "Bifunctor", package: "swift-bifunctor", condition: .when(traits: ["OpticAlgebraIntegration"])),
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
                .product(name: "Coproduct Syntax", package: "swift-coproduct", condition: .when(traits: ["CaseMacro"])),
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
                .product(name: "Coproduct Syntax", package: "swift-coproduct", condition: .when(traits: ["CaseMacro", "FoldMacro"])),
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
                .product(name: "Type Algebra Syntax", package: "swift-algebra", condition: .when(traits: ["IsomorphismMacro"])),
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
                .product(name: "Type Algebra Syntax", package: "swift-algebra", condition: .when(traits: ["LensMacro", "TraversalMacro"])),
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
                .product(name: "Coproduct Syntax", package: "swift-coproduct", condition: .when(traits: ["CaseMacro", "PrismMacro"])),
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
                .product(name: "Type Algebra Syntax", package: "swift-algebra", condition: .when(traits: ["TraversalMacro"])),
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
