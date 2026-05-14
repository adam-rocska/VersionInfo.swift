# Changelog

All notable changes to this package are documented here.

## 1.0.0 - 2026-05-14

### Added

- Added `VersionInfoPlugin`, a Swift Package Manager build tool plugin that
  generates static Git version information for a target.
- Added generated `versions` data with `head`, `heads`, and `tags`.
- Added support for loose Git refs, packed refs, `.git` files with `gitdir:`
  indirection, symbolic `HEAD`, detached `HEAD`, and nested ref names.
- Added the `VersionInfo` library product.
- Added `Version`, a tuple typealias matching the generated ref shape.
- Added `SemanticVersion` with strict parsing for `major.minor.patch`,
  prerelease identifiers, and build metadata.
- Added `Codable`, `Comparable`, `Hashable`, `RawRepresentable`,
  `LosslessStringConvertible`, `ExpressibleByStringLiteral`, and `Sendable`
  support for `SemanticVersion`.
- Added `SemanticVersion.isCompatible(with:)`.
- Added the `version-info-gen` executable product.
- Added unit, integration, regression-prepared, and user acceptance test
  coverage using Swift Testing.
- Added DocC documentation and a release-focused README.

### Notes

- Build metadata is preserved for display and encoding, but it is not used for
  equality, hashing, or ordering. This follows SemVer precedence rules.
- The plugin reads Git metadata at build time and does not add a runtime Git
  dependency to consumer applications.
- The library and generated Swift source are intended for cross-platform Swift
  targets, including Linux, Android, and WebAssembly/WASI. Linux testing and
  Android/Wasm cross-builds are release gates for the `1.0.0` tag.
