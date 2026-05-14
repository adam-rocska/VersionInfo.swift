import Foundation
import Testing
@testable import VersionInfo

@Suite("SemanticVersion edge cases")
struct SemanticVersionEdgeCaseTests {
  @Test("Public memberwise initializer preserves component values")
  func memberwiseInitializer() {
    let version = SemanticVersion(major: 12, minor: 34, patch: 56)

    #expect(version.major == 12)
    #expect(version.minor == 34)
    #expect(version.patch == 56)
  }

  @Test("String literal initializer builds a valid version")
  func stringLiteralInitializer() {
    let version: SemanticVersion = "7.8.9"

    #expect(version == SemanticVersion(major: 7, minor: 8, patch: 9))
  }

  @Test("Conforms to LosslessStringConvertible")
  func losslessStringConvertibleConformance() {
    let version = SemanticVersion(major: 1, minor: 2, patch: 3)

    #expect(roundTrip(version) == version)
  }

  @Test("Conforms to Sendable")
  func sendableConformance() {
    requireSendable(SemanticVersion(major: 1, minor: 2, patch: 3))
  }

  @Test(
    "Rejects signed or negative numeric components",
    arguments: [
      "-1.2.3",
      "1.-2.3",
      "1.2.-3",
      "+1.2.3",
      "1.+2.3",
      "1.2.+3",
    ]
  )
  func rejectsSignedComponents(input: String) {
    #expect(SemanticVersion(input) == nil)
  }

  @Test(
    "Rejects leading or trailing whitespace",
    arguments: [
      " 1.2.3",
      "1.2.3 ",
      "\t1.2.3",
      "1.2.3\n",
    ]
  )
  func rejectsWhitespace(input: String) {
    #expect(SemanticVersion(input) == nil)
  }

  @Test(
    "Rejects empty numeric components",
    arguments: [
      ".1.2",
      "1..2",
      "1.2.",
      "1...2",
    ]
  )
  func rejectsEmptyComponents(input: String) {
    #expect(SemanticVersion(input) == nil)
  }

  @Test("Rejects invalid generated Version tuple names")
  func rejectsInvalidVersionTupleNames() {
    #expect(SemanticVersion((name: "not-a-version", hash: "abc123")) == nil)
    #expect(SemanticVersion((name: "1.2", hash: "abc123")) == nil)
  }

  @Test("RawRepresentable rejects invalid raw values")
  func rawRepresentableRejectsInvalidValues() {
    #expect(SemanticVersion(rawValue: "1.2") == nil)
    #expect(SemanticVersion(rawValue: "one.two.three") == nil)
  }

  @Test("Comparable treats equal components as equal and not less-than")
  func comparableEqualityBoundary() {
    let lhs = SemanticVersion(major: 1, minor: 2, patch: 3)
    let rhs = SemanticVersion(major: 1, minor: 2, patch: 3)

    #expect(lhs == rhs)
    #expect(!(lhs < rhs))
    #expect(!(rhs < lhs))
  }

  @Test("Compatibility ignores patch and is directional by minor version")
  func compatibilityBoundaries() {
    let version = SemanticVersion(major: 2, minor: 4, patch: 9)

    #expect(version.isCompatible(with: SemanticVersion(major: 2, minor: 4, patch: 0)))
    #expect(version.isCompatible(with: SemanticVersion(major: 2, minor: 5, patch: 0)))
    #expect(!version.isCompatible(with: SemanticVersion(major: 2, minor: 3, patch: 99)))
    #expect(!version.isCompatible(with: SemanticVersion(major: 3, minor: 4, patch: 9)))
  }

  @Test("Codable rejects non-string JSON values")
  func codableRejectsNonStringValues() {
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(SemanticVersion.self, from: Data("123".utf8))
    }
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(SemanticVersion.self, from: Data("{\"version\":\"1.2.3\"}".utf8))
    }
  }

  private func roundTrip<T>(_ value: T) -> T?
  where T: LosslessStringConvertible {
    T(value.description)
  }

  private func requireSendable<T>(_ value: T)
  where T: Sendable {}
}
