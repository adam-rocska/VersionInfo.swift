# Semantic Version Guide

Use `SemanticVersion` to parse, compare, encode, and decode semantic versions.

## Parse a Version

```swift
let version = SemanticVersion("1.2.3")
```

The initializer returns `nil` for malformed input:

```swift
SemanticVersion("1.2")
// nil
```

Prerelease identifiers and build metadata are supported:

```swift
let candidate = SemanticVersion("1.0.0-rc.1+build.42")!

print(candidate.prerelease)
// Optional("rc.1")

print(candidate.buildMetadata)
// Optional("build.42")
```

## Compare Versions

Versions compare by SemVer precedence:

```swift
let alpha = SemanticVersion("1.0.0-alpha")!
let release = SemanticVersion("1.0.0")!

print(alpha < release)
// true
```

Prerelease identifiers are compared identifier by identifier:

```swift
let ordered: [SemanticVersion] = [
  "1.0.0-alpha",
  "1.0.0-alpha.1",
  "1.0.0-alpha.beta",
  "1.0.0-beta",
  "1.0.0-beta.2",
  "1.0.0-beta.11",
  "1.0.0-rc.1",
  "1.0.0",
]
```

Numeric prerelease identifiers are compared by numeric value without converting
to `Int`, so very large identifiers do not overflow.

## Build Metadata

Build metadata is retained:

```swift
let version = SemanticVersion("1.0.0+ci.42")!

print(version.description)
// 1.0.0+ci.42
```

Build metadata is not used for equality, hashing, or ordering:

```swift
let local = SemanticVersion("1.0.0+local")!
let ci = SemanticVersion("1.0.0+ci")!

print(local == ci)
// true
```

This follows SemVer precedence rules. Build metadata describes a build of a
version, not a separate release version.

## Compatibility

Use ``SemanticVersion/isCompatible(with:)`` to compare package-style
compatibility:

```swift
let baseline = SemanticVersion("1.2.3")!

baseline.isCompatible(with: "1.3.0")
// true

baseline.isCompatible(with: "2.0.0")
// false
```

Compatibility requires the same major version and an equal or newer minor
version. Patch, prerelease, and build metadata do not affect compatibility.

## Codable

`SemanticVersion` encodes as a single string:

```swift
let encoded = try JSONEncoder().encode(SemanticVersion("1.2.3")!)
```

Decoding validates the string before creating a value.
