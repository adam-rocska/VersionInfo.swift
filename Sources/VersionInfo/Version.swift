/// A Git ref resolved at build time.
///
/// The build tool plugin generates values with this tuple shape so generated
/// refs can be used without linking the `VersionInfo` library. Library users
/// can pass the same tuple directly to ``SemanticVersion/init(_:)-(Version)``.
public typealias Version = (name: String, hash: String)
