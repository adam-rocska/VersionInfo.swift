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
    let components = string.split(separator: ".").map(String.init)
    guard components.count == 3,
      let major = Int(components[0]),
      let minor = Int(components[1]),
      let patch = Int(components[2])
    else {
      return nil
    }
    self.init(major: major, minor: minor, patch: patch)
  }

  public init?(_ version: Version) { self.init(version.name) }

}
