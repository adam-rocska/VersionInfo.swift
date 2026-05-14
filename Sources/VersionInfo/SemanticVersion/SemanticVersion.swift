public struct SemanticVersion: Sendable {
  public let major: Int
  public let minor: Int
  public let patch: Int
  public let prerelease: String?
  public let buildMetadata: String?

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
