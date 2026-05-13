public struct SemanticVersion {
  public let major: Int
  public let minor: Int
  public let patch: Int

  public init(major: Int, minor: Int, patch: Int) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }

  public init?(_ string: String) {
    let components = string.split(
      separator: ".",
      omittingEmptySubsequences: false
    )
    guard components.count == 3,
      let major = Int(versionComponent: components[0]),
      let minor = Int(versionComponent: components[1]),
      let patch = Int(versionComponent: components[2])
    else {
      return nil
    }
    self.init(major: major, minor: minor, patch: patch)
  }

  public init?(_ version: Version) { self.init(version.name) }
}

extension Int {
  fileprivate init?<VersionComponent>(
    versionComponent component: VersionComponent
  )
  where VersionComponent: StringProtocol {
    guard !component.isEmpty else { return nil }
    guard component.allSatisfy(\.isNumber) else { return nil }
    self.init(component)
  }
}
