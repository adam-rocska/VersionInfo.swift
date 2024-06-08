extension SemanticVersion: Equatable {
  public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
  }
}
