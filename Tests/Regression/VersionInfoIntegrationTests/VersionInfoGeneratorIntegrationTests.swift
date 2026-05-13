import Foundation
import Testing
import VersionInfoTestSupport

@Suite("version-info-gen CLI", .serialized, .timeLimit(.minutes(2)))
struct VersionInfoGeneratorIntegrationTests {
  @Test("Writes generated Swift code to an output directory")
  func writesGeneratedSwiftFile() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.create(
      in: temporaryDirectory.url,
      branches: [
        "main": GitFixture.mainHash,
        "release": GitFixture.releaseHash,
      ],
      tags: [
        "1.2.3": GitFixture.tagHash
      ]
    )
    let outputDirectory = try temporaryDirectory.createDirectory("generated")
    let swiftPM = try SwiftPM(
      workingDirectory: PackagePaths.root,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    )

    _ = try swiftPM.run([
      "run",
      "version-info-gen",
      fixture.gitDirectory.path,
      "--output-dir",
      outputDirectory.path,
    ])

    let generated = try String(
      contentsOf: outputDirectory.appendingPathComponent("VersionInfo.swift"),
      encoding: .utf8
    )

    #expect(generated.contains("typealias Version = (name: String, hash: String)"))
    #expect(generated.contains("head: (\"main\", \"\(GitFixture.mainHash)\")"))
    #expect(generated.contains("(\"release\", \"\(GitFixture.releaseHash)\")"))
    #expect(generated.contains("(\"1.2.3\", \"\(GitFixture.tagHash)\")"))
  }

  @Test("Prints generated Swift code when no output directory is provided")
  func printsGeneratedSwiftCode() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.create(in: temporaryDirectory.url)
    let swiftPM = try SwiftPM(
      workingDirectory: PackagePaths.root,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    )

    let result = try swiftPM.run([
      "run",
      "version-info-gen",
      fixture.gitDirectory.path,
    ])

    #expect(result.stdout.contains("let versions: Versions = ("))
    #expect(result.stdout.contains("head: (\"main\", \"\(GitFixture.mainHash)\")"))
  }

  @Test("Fails with a validation error for a missing .git directory")
  func failsForMissingGitDirectory() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let missingGitDirectory = temporaryDirectory.appending("missing.git")
    let swiftPM = try SwiftPM(
      workingDirectory: PackagePaths.root,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    )

    let result = try swiftPM.runAllowingFailure([
      "run",
      "version-info-gen",
      missingGitDirectory.path,
    ])

    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("Couldn't read refs"))
  }

  @Test("Creates a missing output directory before writing generated code")
  func createsMissingOutputDirectory() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.create(in: temporaryDirectory.url)
    let outputDirectory = temporaryDirectory.appending("missing", "generated", "directory")
    let swiftPM = try SwiftPM(
      workingDirectory: PackagePaths.root,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    )

    _ = try swiftPM.run([
      "run",
      "version-info-gen",
      fixture.gitDirectory.path,
      "--output-dir",
      outputDirectory.path,
    ])

    #expect(FileManager.default.fileExists(atPath: outputDirectory.path))
    #expect(FileManager.default.fileExists(
      atPath: outputDirectory.appendingPathComponent("VersionInfo.swift").path
    ))
  }

  @Test("Generated code is syntactically valid Swift for simple refs")
  func generatedCodeIsValidSwift() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.create(in: temporaryDirectory.url)
    let outputDirectory = try temporaryDirectory.createDirectory("generated")
    let swiftPM = try SwiftPM(
      workingDirectory: PackagePaths.root,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    )

    _ = try swiftPM.run([
      "run",
      "version-info-gen",
      fixture.gitDirectory.path,
      "--output-dir",
      outputDirectory.path,
    ])

    _ = try ProcessRunner.requireSuccess(
      PackagePaths.swiftExecutable,
      arguments: [outputDirectory.appendingPathComponent("VersionInfo.swift").path]
    )
  }

  @Test("Escapes generated Swift string literals for ref names")
  func escapesGeneratedSwiftStringLiterals() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.create(
      in: temporaryDirectory.url,
      branches: [
        "main": GitFixture.mainHash,
        "release\"candidate": GitFixture.releaseHash,
      ],
      tags: [
        "1.2.3\"quoted": GitFixture.tagHash
      ]
    )
    let outputDirectory = try temporaryDirectory.createDirectory("generated")
    let swiftPM = try SwiftPM(
      workingDirectory: PackagePaths.root,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    )

    _ = try swiftPM.run([
      "run",
      "version-info-gen",
      fixture.gitDirectory.path,
      "--output-dir",
      outputDirectory.path,
    ])

    let generatedFile = outputDirectory.appendingPathComponent("VersionInfo.swift")
    let generated = try String(contentsOf: generatedFile, encoding: .utf8)

    #expect(generated.contains(#""release\"candidate""#))
    #expect(generated.contains(#""1.2.3\"quoted""#))
    _ = try ProcessRunner.requireSuccess(
      PackagePaths.swiftExecutable,
      arguments: [generatedFile.path]
    )
  }
}
