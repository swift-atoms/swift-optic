import Foundation
import Testing

@Suite
private struct `Compiler Tests` {
    @Test
    func `Adapter failure axes and ownership compile exactly`() throws {
        try typecheckSuccess(named: "Adapter Capabilities.swift")
    }

    @Test
    func `relaxing either result position loses nonescapable inputs`() throws {
        let diagnostic = try typecheckFailure(
            named: "Nonescapable Escaping Result.swift"
        )

        #expect(diagnostic.contains("type 'TargetProbeSource' does not conform to protocol 'Escapable'"))
        #expect(diagnostic.contains("type 'FocusProbeSource' does not conform to protocol 'Escapable'"))
    }

    private func typecheckFailure(named name: String) throws -> String {
        var products = URL(fileURLWithPath: Bundle.module.bundlePath)
        for _ in 0..<12 {
            if FileManager.default.fileExists(
                atPath: products.appendingPathComponent("Either.swiftmodule").path
            ) {
                break
            }
            products = URL(fileURLWithPath: products.path)
                .deletingLastPathComponent()
        }
        try #require(
            FileManager.default.fileExists(
                atPath: products.appendingPathComponent("Either.swiftmodule").path
            )
        )
        let fixture = Bundle.module.resourceURL!
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)
        let library = Bundle.module.resourceURL!
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("Nonescapable Escaping Result Library.swift")
        let scratch = FileManager.default.temporaryDirectory
            .appendingPathComponent("swift-optic-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: scratch,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: scratch) }

        let libraryProcess = Process()
        let libraryError = Pipe()
        libraryProcess.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        libraryProcess.arguments = [
            "swiftc",
            "-emit-module",
            "-parse-as-library",
            "-swift-version", "6",
            "-strict-memory-safety",
            "-enable-experimental-feature", "Lifetimes",
            "-enable-experimental-feature", "MoveOnlyTuples",
            "-module-name", "ArrowFixture",
            "-emit-module-path",
            scratch.appendingPathComponent("ArrowFixture.swiftmodule").path,
            "-I", products.path,
            "-I", products.appendingPathComponent("Modules").path,
            library.path,
        ]
        libraryProcess.standardError = libraryError
        try libraryProcess.run()
        libraryProcess.waitUntilExit()
        let libraryDiagnostic = String(
            decoding: libraryError.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )
        try #require(
            libraryProcess.terminationStatus == 0,
            "Fixture library did not compile:\n\(libraryDiagnostic)"
        )

        let process = Process()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc",
            "-typecheck",
            "-swift-version", "6",
            "-strict-memory-safety",
            "-enable-experimental-feature", "Lifetimes",
            "-enable-experimental-feature", "MoveOnlyTuples",
            "-module-name", "Proof",
            "-I", products.path,
            "-I", products.appendingPathComponent("Modules").path,
            "-I", scratch.path,
            fixture.path,
        ]
        process.standardError = standardError
        try process.run()
        process.waitUntilExit()
        let diagnostic = String(
            decoding: standardError.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )

        #expect(process.terminationStatus != 0, "Fixture unexpectedly typechecked")
        #expect(!diagnostic.contains("no such module"))
        return diagnostic
    }

    private func typecheckSuccess(named name: String) throws {
        var products = URL(fileURLWithPath: Bundle.module.bundlePath)
        for _ in 0..<12 {
            if FileManager.default.fileExists(
                atPath: products.appendingPathComponent("Optic.swiftmodule").path
            ) {
                break
            }
            products = URL(fileURLWithPath: products.path)
                .deletingLastPathComponent()
        }
        try #require(
            FileManager.default.fileExists(
                atPath: products.appendingPathComponent("Optic.swiftmodule").path
            )
        )
        let fixture = Bundle.module.resourceURL!
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)
        let process = Process()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc",
            "-typecheck",
            "-swift-version", "6",
            "-strict-memory-safety",
            "-enable-upcoming-feature", "ExistentialAny",
            "-enable-upcoming-feature", "InternalImportsByDefault",
            "-enable-upcoming-feature", "MemberImportVisibility",
            "-enable-upcoming-feature", "NonisolatedNonsendingByDefault",
            "-enable-experimental-feature", "Lifetimes",
            "-enable-experimental-feature", "MoveOnlyTuples",
            "-module-name", "Proof",
            "-I", products.path,
            "-I", products.appendingPathComponent("Modules").path,
            fixture.path,
        ]
        process.standardError = standardError
        try process.run()
        process.waitUntilExit()
        let diagnostic = String(
            decoding: standardError.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )

        #expect(
            process.terminationStatus == 0,
            "Fixture did not typecheck:\n\(diagnostic)"
        )
    }
}
