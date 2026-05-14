extension SemanticVersion: RawRepresentable {
  /// The canonical semantic version string.
  public var rawValue: String { description }

  /// Creates a semantic version from a canonical string.
  public init?(rawValue: String) { self.init(rawValue) }
}
