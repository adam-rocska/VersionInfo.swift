extension SemanticVersion: CustomStringConvertible {
  /// The canonical string representation of the semantic version.
  public var description: String {
    var description = "\(major).\(minor).\(patch)"
    if let prerelease { description += "-\(prerelease)" }
    if let buildMetadata { description += "+\(buildMetadata)" }
    return description
  }
}
