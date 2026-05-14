import Foundation
import Testing
@testable import VersionInfo

@Suite("SemanticVersion metadata")
struct SemanticVersionMetadataTests {
  @Test("Parses prerelease and build metadata")
  func parsesPrereleaseAndBuildMetadata() throws {
    let version = try #require(SemanticVersion(String("1.2.3-alpha.1+build.42")))

    #expect(version.major == 1)
    #expect(version.minor == 2)
    #expect(version.patch == 3)
    #expect(version.prerelease == "alpha.1")
    #expect(version.buildMetadata == "build.42")
    #expect(version.description == "1.2.3-alpha.1+build.42")
  }

  @Test("Component initializer accepts valid metadata")
  func componentInitializerAcceptsMetadata() {
    let version = SemanticVersion(
      major: 1,
      minor: 2,
      patch: 3,
      prerelease: "rc.1",
      buildMetadata: "exp.sha.5114f85"
    )

    #expect(version.description == "1.2.3-rc.1+exp.sha.5114f85")
  }

  @Test(
    "Accepts valid SemVer metadata forms",
    arguments: [
      "1.0.0-alpha",
      "1.0.0-alpha.1",
      "1.0.0-0.3.7",
      "1.0.0-x.7.z.92",
      "1.0.0+20130313144700",
      "1.0.0-beta+exp.sha.5114f85",
      "1.0.0+21AF26D3----117B344092BD",
    ]
  )
  func acceptsValidMetadataForms(input: String) throws {
    let version = try #require(SemanticVersion(input))

    #expect(version.description == input)
  }

  @Test(
    "Rejects invalid SemVer metadata forms",
    arguments: [
      "01.0.0",
      "1.02.0",
      "1.0.03",
      "1.0.0-",
      "1.0.0+",
      "1.0.0-alpha.",
      "1.0.0-alpha..1",
      "1.0.0+build.",
      "1.0.0+build..1",
      "1.0.0-alpha_1",
      "1.0.0+build_1",
      "1.0.0-alpha+build+extra",
      "1.0.0-01",
      "1.0.0-alpha.01",
      "1.0.0-α",
      "１.0.0",
    ]
  )
  func rejectsInvalidMetadataForms(input: String) {
    #expect(SemanticVersion(input) == nil)
  }

  @Test("Orders prerelease identifiers by SemVer precedence")
  func ordersPrereleaseIdentifiers() throws {
    let ordered: [SemanticVersion] = try [
      "1.0.0-alpha",
      "1.0.0-alpha.1",
      "1.0.0-alpha.beta",
      "1.0.0-beta",
      "1.0.0-beta.2",
      "1.0.0-beta.11",
      "1.0.0-rc.1",
      "1.0.0",
    ].map { try #require(SemanticVersion($0)) }

    #expect(ordered == ordered.shuffled().sorted())
  }

  @Test("Compares numeric prerelease identifiers without integer overflow")
  func comparesHugeNumericPrereleaseIdentifiers() throws {
    let lower = try #require(
      SemanticVersion(String("1.0.0-alpha.9999999999999999999999999"))
    )
    let higher = try #require(
      SemanticVersion(String("1.0.0-alpha.10000000000000000000000000"))
    )

    #expect(lower < higher)
  }

  @Test("Build metadata does not affect precedence or hashing")
  func buildMetadataDoesNotAffectPrecedenceOrHashing() throws {
    let local = try #require(SemanticVersion(String("1.0.0+local.1")))
    let ci = try #require(SemanticVersion(String("1.0.0+ci.2")))

    #expect(local == ci)
    #expect(!(local < ci))
    #expect(!(ci < local))
    #expect(local <= ci)
    #expect(ci <= local)
    #expect(Set([local, ci]).count == 1)
  }

  @Test("Codable preserves prerelease and build metadata")
  func codablePreservesMetadata() throws {
    let version = try #require(SemanticVersion(String("2.0.0-rc.1+build.5")))
    let encoded = try JSONEncoder().encode(version)
    let decoded = try JSONDecoder().decode(SemanticVersion.self, from: encoded)

    #expect(String(data: encoded, encoding: .utf8) == "\"2.0.0-rc.1+build.5\"")
    #expect(decoded.description == "2.0.0-rc.1+build.5")
    #expect(decoded == version)
  }

  @Test("RawRepresentable and Version tuple parsing accept metadata")
  func rawRepresentableAndVersionTupleParsingAcceptMetadata() throws {
    let raw = try #require(SemanticVersion(rawValue: "2.0.0-beta.2+build.7"))
    let tuple = try #require(
      SemanticVersion((name: "2.0.0-beta.2+build.7", hash: "abc123"))
    )

    #expect(raw.description == "2.0.0-beta.2+build.7")
    #expect(tuple.description == "2.0.0-beta.2+build.7")
    #expect(tuple == raw)
  }
}
