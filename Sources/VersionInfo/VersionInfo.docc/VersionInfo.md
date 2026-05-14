# ``VersionInfo``

Build-time Git version information and semantic version tools for Swift
packages.

## Overview

VersionInfo.swift helps a Swift package know what it was built from.

The package has two parts:

- `VersionInfoPlugin`, a Swift Package Manager build tool plugin that generates
  a `versions` value in your target.
- `VersionInfo`, a library that parses, compares, encodes, and decodes semantic
  versions.

You can use the plugin without the library, the library without the plugin, or
both together.

The plugin reads Git metadata at build time and emits Swift source. Your
application does not need to call `git` at runtime.

The library and generated Swift source are intended for cross-platform Swift
targets, including Apple platforms, Linux, Android, and WebAssembly/WASI. The
plugin and generator run on the build host, so cross-compilation depends on the
host SwiftPM toolchain and the target Swift SDK.

## Generated Values

The plugin generates a value named `versions`:

```swift
typealias Version = (name: String, hash: String)
typealias Versions = (head: Version, heads: [Version], tags: [Version])

let versions: Versions
```

The generated tuple shape intentionally matches ``Version``. This lets library
users pass generated refs directly to ``SemanticVersion/init(_:)``.

## Semantic Versions

Use ``SemanticVersion`` for strict semantic version parsing and comparison:

```swift
let release = SemanticVersion("1.0.0")!
let candidate = SemanticVersion("1.0.0-rc.1")!

print(candidate < release)
// true
```

Build metadata is preserved for display and encoding, but it is not part of
equality, hashing, or ordering.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:GeneratedVersionInformation>
- <doc:SemanticVersionGuide>

### Generated Git Refs

- ``Version``

### Semantic Versions

- ``SemanticVersion``
