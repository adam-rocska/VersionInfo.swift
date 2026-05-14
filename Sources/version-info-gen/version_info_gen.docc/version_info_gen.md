# ``version_info_gen``

Generate Swift source containing Git version information.

@Metadata {
  @DisplayName("version-info-gen")
}

## Overview

`version-info-gen` is the executable used by `VersionInfoPlugin`.

The executable reads Git metadata from a `.git` directory, resolves the current
`HEAD`, branch refs, and tag refs, then writes a Swift file containing a static
`versions` value.

Most users should use `VersionInfoPlugin` instead of calling this executable
directly. The executable exists as a separate product so the build tool plugin
can invoke it through Swift Package Manager.

## Usage

Print generated Swift source:

```sh
swift run version-info-gen .git
```

Write generated Swift source to a directory:

```sh
swift run version-info-gen .git --output-dir Generated
```

The generated file contains this shape:

```swift
typealias Version = (name: String, hash: String)
typealias Versions = (head: Version, heads: [Version], tags: [Version])

let versions: Versions
```

## Git Metadata

The generator supports:

- loose refs
- packed refs
- `.git` files with `gitdir: ...` indirection
- symbolic `HEAD`
- detached `HEAD`
- nested branch and tag names
