import Foundation
import Testing
import VersionInfoTestSupport
@testable import version_info_gen

@Suite("Git reference loading")
struct GitReferenceTests {
  @Test("Reads HEAD, branches, and tags from loose refs")
  func readsLooseRefs() throws {
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

    let refs = try #require(Refs(gitDir: fixture.gitDirectory))

    #expect(refs.head.matches(name: "main", hash: GitFixture.mainHash))
    #expect(refs.heads.containsRef(name: "main", hash: GitFixture.mainHash))
    #expect(refs.heads.containsRef(name: "release", hash: GitFixture.releaseHash))
    #expect(refs.tags.containsRef(name: "1.2.3", hash: GitFixture.tagHash))
  }

  @Test("Preserves nested branch and tag names")
  func preservesNestedRefNames() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.create(
      in: temporaryDirectory.url,
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

    let refs = try #require(Refs(gitDir: fixture.gitDirectory))

    #expect(refs.head.matches(name: "feature/swift-6", hash: GitFixture.featureHash))
    #expect(refs.heads.containsRef(name: "release/2026.05", hash: GitFixture.releaseHash))
    #expect(refs.tags.containsRef(name: "release/1.2.3", hash: GitFixture.tagHash))
  }

  @Test("Reads detached HEAD checkouts")
  func readsDetachedHead() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.createDetachedHead(
      in: temporaryDirectory.url,
      headHash: GitFixture.mainHash,
      branches: [
        "main": GitFixture.mainHash
      ]
    )

    let refs = try #require(Refs(gitDir: fixture.gitDirectory))

    #expect(refs.head.matches(name: "HEAD", hash: GitFixture.mainHash))
    #expect(refs.heads.containsRef(name: "main", hash: GitFixture.mainHash))
  }

  @Test("Returns nil when HEAD cannot be read")
  func returnsNilForUnreadableHead() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let gitDirectory = try temporaryDirectory.createDirectory(".git")

    #expect(Refs(gitDir: gitDirectory) == nil)
  }
}

extension Ref {
  fileprivate func matches(name: String, hash: String) -> Bool {
    self.name == name && self.hash == hash
  }
}

extension [Ref] {
  fileprivate func containsRef(name: String, hash: String) -> Bool {
    contains { $0.matches(name: name, hash: hash) }
  }
}
