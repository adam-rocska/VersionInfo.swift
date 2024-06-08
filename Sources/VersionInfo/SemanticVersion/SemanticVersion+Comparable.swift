extension SemanticVersion: Comparable {
  public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    guard lhs.major == rhs.major else { return lhs.major < rhs.major }
    guard lhs.minor == rhs.minor else { return lhs.minor < rhs.minor }
    return lhs.patch < rhs.patch
  }
}
