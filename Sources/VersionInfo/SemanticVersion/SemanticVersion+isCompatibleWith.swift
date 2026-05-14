extension SemanticVersion {
  /// Returns whether another version is compatible with this version.
  ///
  /// Compatibility requires the same major version and an equal or newer minor
  /// version. Patch, prerelease, and build metadata do not affect compatibility.
  public func isCompatible(with version: SemanticVersion) -> Bool {
    guard major == version.major else { return false }
    guard minor <= version.minor else { return false }
    return true
  }
}
