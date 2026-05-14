/// A semantic version.
///
/// `SemanticVersion` parses and compares SemVer-style values such as `1.2.3`,
/// `1.2.3-rc.1`, and `1.2.3+build.42`.
public struct SemanticVersion: Sendable {
  /// The major version component.
  public let major: Int

  /// The minor version component.
  public let minor: Int

  /// The patch version component.
  public let patch: Int

  /// The prerelease identifiers, without the leading hyphen.
  ///
  /// For `1.0.0-rc.1`, this value is `rc.1`.
  public let prerelease: String?

  /// The build metadata identifiers, without the leading plus sign.
  ///
  /// Build metadata is preserved in ``description`` and `Codable` output, but
  /// it is not used for equality, hashing, or ordering.
  public let buildMetadata: String?

  /// Creates a semantic version from its components.
  ///
  /// Invalid metadata values assert in debug builds and are ignored in optimized
  /// builds. Prefer ``init(_:)-(String)`` when accepting user or external input.
  public init(
    major: Int,
    minor: Int,
    patch: Int,
    prerelease: String? = nil,
    buildMetadata: String? = nil
  ) {
    assert(
      prerelease?.isValidPrerelease != false,
      "Invalid semantic version prerelease identifiers."
    )
    assert(
      buildMetadata?.isValidBuildMetadata != false,
      "Invalid semantic version build metadata identifiers."
    )

    self.major = major
    self.minor = minor
    self.patch = patch
    self.prerelease = prerelease?.isValidPrerelease == true ? prerelease : nil
    self.buildMetadata =
      buildMetadata?.isValidBuildMetadata == true
      ? buildMetadata
      : nil
  }

  /// Creates a semantic version by parsing a string.
  ///
  /// The parser accepts `major.minor.patch`, optional prerelease identifiers,
  /// and optional build metadata. It rejects malformed versions, empty
  /// components, non-ASCII identifiers, and numeric identifiers with invalid
  /// leading zeroes.
  public init?(_ string: String) {
    let buildComponents = string.split(
      separator: "+",
      maxSplits: 1,
      omittingEmptySubsequences: false
    )
    let buildMetadata =
      buildComponents.count == 2
      ? String(buildComponents[1])
      : nil
    guard buildMetadata?.isValidBuildMetadata != false else { return nil }

    let versionComponents = buildComponents[0].split(
      separator: "-",
      maxSplits: 1,
      omittingEmptySubsequences: false
    )
    let prerelease =
      versionComponents.count == 2
      ? String(versionComponents[1])
      : nil
    guard prerelease?.isValidPrerelease != false else { return nil }

    let components = versionComponents[0].split(
      separator: ".",
      omittingEmptySubsequences: false
    )
    guard components.count == 3,
      let major = Int(versionCoreComponent: components[0]),
      let minor = Int(versionCoreComponent: components[1]),
      let patch = Int(versionCoreComponent: components[2])
    else {
      return nil
    }

    self.init(
      major: major,
      minor: minor,
      patch: patch,
      prerelease: prerelease,
      buildMetadata: buildMetadata
    )
  }

  /// Creates a semantic version from a generated Git ref tuple.
  ///
  /// The tuple's `name` field is parsed as a semantic version.
  public init?(_ version: Version) { self.init(version.name) }
}

extension Int {
  fileprivate init?<VersionCoreComponent>(
    versionCoreComponent component: VersionCoreComponent
  )
  where VersionCoreComponent: StringProtocol {
    guard component.isValidSemVerCoreNumericIdentifier else { return nil }
    self.init(component)
  }
}

extension StringProtocol {
  fileprivate var isValidPrerelease: Bool {
    isValidSemVerIdentifierList(allowingLeadingZeroes: false)
  }

  fileprivate var isValidBuildMetadata: Bool {
    isValidSemVerIdentifierList(allowingLeadingZeroes: true)
  }

  fileprivate var isValidSemVerCoreNumericIdentifier: Bool {
    isASCIINumeric && !hasLeadingZero
  }

  fileprivate var isASCIINumeric: Bool {
    !isEmpty && utf8.allSatisfy(\.isASCIIDigit)
  }

  fileprivate var hasLeadingZero: Bool {
    utf8.count > 1 && utf8.first == 48
  }

  fileprivate func isValidSemVerIdentifierList(
    allowingLeadingZeroes: Bool
  ) -> Bool {
    let identifiers = split(
      separator: ".",
      omittingEmptySubsequences: false
    )

    return !identifiers.isEmpty
      && identifiers.allSatisfy {
        $0.isValidSemVerIdentifier(allowingLeadingZeroes: allowingLeadingZeroes)
      }
  }

  fileprivate func isValidSemVerIdentifier(
    allowingLeadingZeroes: Bool
  ) -> Bool {
    guard !isEmpty else { return false }
    guard utf8.allSatisfy(\.isSemVerIdentifier) else { return false }
    guard allowingLeadingZeroes || !isASCIINumeric || !hasLeadingZero else {
      return false
    }
    return true
  }
}

extension UInt8 {
  fileprivate var isASCIIDigit: Bool {
    48...57 ~= self
  }

  fileprivate var isASCIIUppercaseLetter: Bool {
    65...90 ~= self
  }

  fileprivate var isASCIILowercaseLetter: Bool {
    97...122 ~= self
  }

  fileprivate var isSemVerIdentifier: Bool {
    isASCIIDigit || isASCIIUppercaseLetter || isASCIILowercaseLetter
      || self == 45
  }
}
