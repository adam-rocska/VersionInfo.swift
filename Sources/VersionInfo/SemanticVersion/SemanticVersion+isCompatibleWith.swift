extension SemanticVersion {
  public func isCompatible(with version: SemanticVersion) -> Bool {
    guard major == version.major else { return false }
    guard minor <= version.minor else { return false }
    return true
  }
}
