extension SemanticVersion: RawRepresentable {
  public var rawValue: String { description }
  public init?(rawValue: String) { self.init(rawValue) }
}
