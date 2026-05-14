extension SemanticVersion: Equatable {
  public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    lhs.major == rhs.major
      && lhs.minor == rhs.minor
      && lhs.patch == rhs.patch
      && lhs.prerelease == rhs.prerelease
    /// TODO: Bundle metadata is not equated for now. But I can't make up my mind. On one hand, strictly speaking two values should be considered equal if their meta also match. On the other hand, onthologically speaking, two versions are equal even if their meta is different. I con't decide for now, so this is the result of a coin-flip. Open a ticket if you don't like it.
  }
}
