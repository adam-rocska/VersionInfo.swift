import Foundation
import Testing
import VersionInfoTestSupport

@Suite("Plugin Git repository shapes", .serialized, .timeLimit(.minutes(3)))
struct PluginGitShapeAcceptanceTests {
  @Test("Plugin preserves nested branch and tag names for consumers")
  func pluginPreservesNestedRefNames() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("NestedRefsConsumer")
    try GitFixture.create(
      in: consumerDirectory,
      headName: "feature/swift-6",
      headHash: GitFixture.featureHash,
      branches: [
        "main": GitFixture.mainHash,
        "release/2026.05": GitFixture.releaseHash,
      ],
      tags: [
        "release/1.2.3": GitFixture.tagHash
      ]
    )

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "NestedRefsConsumer",
      dependencies: "",
      targetDependencies: "",
      plugins: ".plugin(name: \"VersionInfoPlugin\", package: \"VersionInfo.swift\"),",
      main: """
      print("head=\\(versions.head.name):\\(versions.head.hash)")
      print("heads=\\(versions.heads.map(\\.name).sorted().joined(separator: ","))")
      print("tags=\\(versions.tags.map(\\.name).sorted().joined(separator: ","))")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("head=feature/swift-6:\(GitFixture.featureHash)"))
    #expect(result.stdout.contains("heads=feature/swift-6,main,release/2026.05"))
    #expect(result.stdout.contains("tags=release/1.2.3"))
  }

  @Test("Plugin supports detached HEAD consumers")
  func pluginSupportsDetachedHeadConsumers() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("DetachedHeadConsumer")
    try GitFixture.createDetachedHead(
      in: consumerDirectory,
      headHash: GitFixture.mainHash,
      branches: [
        "main": GitFixture.mainHash
      ],
      tags: [
        "1.2.3": GitFixture.tagHash
      ]
    )

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "DetachedHeadConsumer",
      dependencies: "",
      targetDependencies: "",
      plugins: ".plugin(name: \"VersionInfoPlugin\", package: \"VersionInfo.swift\"),",
      main: """
      print("head=\\(versions.head.name):\\(versions.head.hash)")
      print("heads=\\(versions.heads.map(\\.name).sorted().joined(separator: ","))")
      print("tags=\\(versions.tags.map(\\.name).sorted().joined(separator: ","))")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("head=HEAD:\(GitFixture.mainHash)"))
    #expect(result.stdout.contains("heads=main"))
    #expect(result.stdout.contains("tags=1.2.3"))
  }

  @Test("Plugin handles consumers with no branch or tag refs")
  func pluginHandlesRepositoryWithOnlyHead() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("HeadOnlyConsumer")
    let gitDirectory = try temporaryDirectory.createDirectory("HeadOnlyConsumer", ".git")
    try "ref: refs/heads/main\n".write(
      to: gitDirectory.appendingPathComponent("HEAD"),
      atomically: true,
      encoding: .utf8
    )
    _ = try temporaryDirectory.write(
      "\(GitFixture.mainHash)\n",
      to: "HeadOnlyConsumer",
      ".git",
      "refs",
      "heads",
      "main"
    )

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "HeadOnlyConsumer",
      dependencies: "",
      targetDependencies: "",
      plugins: ".plugin(name: \"VersionInfoPlugin\", package: \"VersionInfo.swift\"),",
      main: """
      print("head=\\(versions.head.name):\\(versions.head.hash)")
      print("heads-count=\\(versions.heads.count)")
      print("tags-count=\\(versions.tags.count)")
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
    #expect(result.stdout.contains("heads-count=1"))
    #expect(result.stdout.contains("tags-count=0"))
  }

  @Test("Plugin reads packed branch and tag refs")
  func pluginReadsPackedRefs() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("PackedRefsConsumer")
    let gitDirectory = try temporaryDirectory.createDirectory("PackedRefsConsumer", ".git")
    try "ref: refs/heads/main\n".write(
      to: gitDirectory.appendingPathComponent("HEAD"),
      atomically: true,
      encoding: .utf8
    )
    _ = try temporaryDirectory.write(
      """
      # pack-refs with: peeled fully-peeled sorted
      \(GitFixture.mainHash) refs/heads/main
      \(GitFixture.releaseHash) refs/heads/release/2026.05
      \(GitFixture.tagHash) refs/tags/release/1.2.3
      ^9999999999999999999999999999999999999999

      """,
      to: "PackedRefsConsumer",
      ".git",
      "packed-refs"
    )

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "PackedRefsConsumer",
      dependencies: "",
      targetDependencies: "",
      plugins: ".plugin(name: \"VersionInfoPlugin\", package: \"VersionInfo.swift\"),",
      main: """
      print("head=\\(versions.head.name):\\(versions.head.hash)")
      print("heads=\\(versions.heads.map(\\.name).sorted().joined(separator: ","))")
      print("tags=\\(versions.tags.map(\\.name).sorted().joined(separator: ","))")
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
    #expect(result.stdout.contains("heads=main,release/2026.05"))
    #expect(result.stdout.contains("tags=release/1.2.3"))
  }

  @Test("Plugin resolves .git files pointing to Git directories")
  func pluginResolvesGitdirFiles() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("GitdirFileConsumer")
    let storageDirectory = try temporaryDirectory.createDirectory("GitStorage")
    try GitFixture.create(in: storageDirectory)
    _ = try temporaryDirectory.write(
      "gitdir: ../GitStorage/.git\n",
      to: "GitdirFileConsumer",
      ".git"
    )

    let consumer = try ConsumerPackage.create(
      in: consumerDirectory,
      name: "GitdirFileConsumer",
      dependencies: "",
      targetDependencies: "",
      plugins: ".plugin(name: \"VersionInfoPlugin\", package: \"VersionInfo.swift\"),",
      main: """
      print("head=\\(versions.head.name):\\(versions.head.hash)")
      print("heads=\\(versions.heads.map(\\.name).sorted().joined(separator: ","))")
      print("tags=\\(versions.tags.map(\\.name).sorted().joined(separator: ","))")
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
    #expect(result.stdout.contains("heads=main"))
    #expect(result.stdout.contains("tags=1.2.3"))
  }
}
