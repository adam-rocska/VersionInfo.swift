extension SemanticVersion: CustomStringConvertible {
  public var description: String {
    var description = "\(major).\(minor).\(patch)"
    if let prerelease { description += "-\(prerelease)" }
    if let buildMetadata { description += "+\(buildMetadata)" }
    return description
  }
}
