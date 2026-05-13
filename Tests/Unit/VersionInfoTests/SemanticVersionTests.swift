import Foundation
import Testing
@testable import VersionInfo

@Suite("SemanticVersion")
struct SemanticVersionTests {
  @Test(
    "Parses three numeric components",
    arguments: [
      ("0.0.0", 0, 0, 0),
      ("1.2.3", 1, 2, 3),
      ("10.20.30", 10, 20, 30),
    ]
  )
  func parsesNumericComponents(input: String, major: Int, minor: Int, patch: Int) throws {
    let version = try #require(SemanticVersion(input))

    #expect(version.major == major)
    #expect(version.minor == minor)
    #expect(version.patch == patch)
  }

  @Test(
    "Rejects malformed version strings",
    arguments: [
      "",
      "1",
      "1.2",
      "1.2.3.4",
      "one.2.3",
      "1.two.3",
      "1.2.three",
    ]
  )
  func rejectsMalformedStrings(input: String) {
    #expect(SemanticVersion(input) == nil)
  }

  @Test("Initializes from the generated Version tuple shape")
  func initializesFromVersionTuple() throws {
    let version = try #require(SemanticVersion((name: "2.4.6", hash: "abc123")))

    #expect(version == SemanticVersion(major: 2, minor: 4, patch: 6))
  }

  @Test("Compares by major, then minor, then patch")
  func comparesByComponentOrder() throws {
    let ordered: [SemanticVersion] = [
      "1.0.0",
      "1.0.1",
      "1.1.0",
      "2.0.0",
    ]
    let version = try #require(SemanticVersion(String("1.2.3")))

    #expect(ordered == ordered.shuffled().sorted())
    #expect(version < SemanticVersion(String("1.2.4"))!)
    #expect(version < SemanticVersion(String("1.3.0"))!)
    #expect(version < SemanticVersion(String("2.0.0"))!)
  }

  @Test("Description and raw value are canonical dotted strings")
  func canonicalStringRepresentations() {
    let version = SemanticVersion(major: 3, minor: 2, patch: 1)

    #expect(version.description == "3.2.1")
    #expect(version.rawValue == "3.2.1")
    #expect(SemanticVersion(rawValue: "3.2.1") == version)
  }

  @Test("Codable stores a single string and validates decoded values")
  func codableRoundTrip() throws {
    let encoded = try JSONEncoder().encode(SemanticVersion(major: 1, minor: 2, patch: 3))
    #expect(String(data: encoded, encoding: .utf8) == "\"1.2.3\"")

    let decoded = try JSONDecoder().decode(SemanticVersion.self, from: encoded)
    #expect(decoded == SemanticVersion(major: 1, minor: 2, patch: 3))

    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(SemanticVersion.self, from: Data("\"1.2\"".utf8))
    }
  }

  @Test("Hashable treats equal versions as the same value")
  func hashableIdentity() {
    let versions: Set<SemanticVersion> = [
      SemanticVersion(major: 1, minor: 2, patch: 3),
      SemanticVersion(major: 1, minor: 2, patch: 3),
      SemanticVersion(major: 1, minor: 2, patch: 4),
    ]

    #expect(versions.count == 2)
  }

  @Test("Compatibility keeps the same major and allows newer minor versions")
  func compatibility() {
    let baseline = SemanticVersion(major: 1, minor: 2, patch: 3)

    #expect(baseline.isCompatible(with: SemanticVersion(major: 1, minor: 2, patch: 0)))
    #expect(baseline.isCompatible(with: SemanticVersion(major: 1, minor: 3, patch: 0)))
    #expect(!baseline.isCompatible(with: SemanticVersion(major: 1, minor: 1, patch: 9)))
    #expect(!baseline.isCompatible(with: SemanticVersion(major: 2, minor: 0, patch: 0)))
  }
}
