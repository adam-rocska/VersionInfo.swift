import Foundation
import Testing
import VersionInfoTestSupport

@Suite("Consumer usage", .serialized, .timeLimit(.minutes(3)))
struct ConsumerUsageTests {
  @Test("A package can use only the build tool plugin")
  func pluginOnlyConsumer() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("PluginOnlyConsumer")
    try GitFixture.create(in: consumerDirectory)

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "PluginOnlyConsumer",
      dependencies: "",
      targetDependencies: "",
      plugins: ".plugin(name: \"VersionInfoPlugin\", package: \"VersionInfo.swift\"),",
      main: """
      print("head=\\(versions.head.name):\\(versions.head.hash)")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("head=main:\(GitFixture.mainHash)"))
  }

  @Test("A package can use only the VersionInfo library")
  func libraryOnlyConsumer() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("LibraryOnlyConsumer")

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "LibraryOnlyConsumer",
      dependencies: ".product(name: \"VersionInfo\", package: \"VersionInfo.swift\"),",
      targetDependencies: "",
      plugins: "",
      main: """
      import VersionInfo

      let currentVersion = SemanticVersion("1.1.0")
      let previousVersion = SemanticVersion("1.0.0")
      print("comparison=\\(currentVersion > previousVersion)")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("comparison=true"))
  }

  @Test("A package can use the plugin and VersionInfo library together")
  func pluginAndLibraryConsumer() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("PluginAndLibraryConsumer")
    try GitFixture.create(
      in: consumerDirectory,
      tags: [
        "2.4.6": GitFixture.tagHash,
        "2.4.6-rc.1+build.7": GitFixture.featureHash,
      ]
    )

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "PluginAndLibraryConsumer",
      dependencies: ".product(name: \"VersionInfo\", package: \"VersionInfo.swift\"),",
      targetDependencies: "",
      plugins: ".plugin(name: \"VersionInfoPlugin\", package: \"VersionInfo.swift\"),",
      main: """
      import VersionInfo

      let releaseRef = versions.tags.first { $0.name == "2.4.6" }!
      let release = SemanticVersion(releaseRef)!
      let prereleaseRef = versions.tags.first { $0.name == "2.4.6-rc.1+build.7" }!
      let prerelease = SemanticVersion(prereleaseRef)!

      print("head=\\(versions.head.name):\\(versions.head.hash)")
      print("release=\\(release)")
      print("prerelease=\\(prerelease)")
      print("metadata=\\(prerelease.prerelease!):\\(prerelease.buildMetadata!)")
      print("releaseOrder=\\(prerelease < release)")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("head=main:\(GitFixture.mainHash)"))
    #expect(result.stdout.contains("release=2.4.6"))
    #expect(result.stdout.contains("prerelease=2.4.6-rc.1+build.7"))
    #expect(result.stdout.contains("metadata=rc.1:build.7"))
    #expect(result.stdout.contains("releaseOrder=true"))
  }
}
