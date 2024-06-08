extension SemanticVersion: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    guard let version = SemanticVersion(string) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid semantic version: \(string)"
      )
    }
    self = version
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }
}
