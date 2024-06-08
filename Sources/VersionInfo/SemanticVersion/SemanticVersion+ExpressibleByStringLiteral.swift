extension SemanticVersion: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    guard let version = SemanticVersion(value) else {
      fatalError("Invalid semantic version: \(value)")
    }
    self = version
  }
}
