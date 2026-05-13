import Foundation
import Testing
import VersionInfoTestSupport
@testable import version_info_gen

@Suite("Ref parsing")
struct RefParsingTests {
  @Test("Reads a loose ref file and trims the hash newline")
  func readsLooseRefFile() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let refFile = try temporaryDirectory.write(
      "\(GitFixture.mainHash)\n",
      to: "refs",
      "heads",
      "main"
    )

    let ref = try #require(Ref(file: refFile))

    #expect(ref.name == "main")
    #expect(ref.hash == GitFixture.mainHash)
  }

  @Test("Rejects missing loose ref files")
  func rejectsMissingRefFile() {
    let missing = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathComponent("missing")

    #expect(Ref(file: missing) == nil)
  }

  @Test("Rejects empty loose ref files")
  func rejectsEmptyRefFile() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let refFile = try temporaryDirectory.write("", to: "refs", "heads", "empty")

    #expect(Ref(file: refFile) == nil)
  }

  @Test("Reads a symbolic HEAD ref")
  func readsSymbolicHead() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.create(in: temporaryDirectory.url)

    let head = try #require(Ref(HEAD: fixture.gitDirectory.appendingPathComponent("HEAD")))

    #expect(head.name == "main")
    #expect(head.hash == GitFixture.mainHash)
  }

  @Test("Reads a symbolic HEAD ref with surrounding whitespace")
  func readsWhitespacePaddedSymbolicHead() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let gitDirectory = try temporaryDirectory.createDirectory(".git")
    _ = try temporaryDirectory.write(
      "  ref: refs/heads/main  \n",
      to: ".git",
      "HEAD"
    )
    _ = try temporaryDirectory.write(
      "\(GitFixture.mainHash)\n",
      to: ".git",
      "refs",
      "heads",
      "main"
    )

    let head = try #require(Ref(HEAD: gitDirectory.appendingPathComponent("HEAD")))

    #expect(head.name == "main")
    #expect(head.hash == GitFixture.mainHash)
  }

  @Test("Reads a detached HEAD hash")
  func readsDetachedHeadHash() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let fixture = try GitFixture.createDetachedHead(in: temporaryDirectory.url)

    let head = try #require(Ref(HEAD: fixture.gitDirectory.appendingPathComponent("HEAD")))

    #expect(head.name == "HEAD")
    #expect(head.hash == GitFixture.mainHash)
  }

  @Test("Rejects symbolic HEAD pointing at a missing ref")
  func rejectsMissingHeadTarget() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let gitDirectory = try temporaryDirectory.createDirectory(".git")
    _ = try temporaryDirectory.write("ref: refs/heads/missing\n", to: ".git", "HEAD")

    #expect(Ref(HEAD: gitDirectory.appendingPathComponent("HEAD")) == nil)
  }
}
