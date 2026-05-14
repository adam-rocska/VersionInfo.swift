# VersionInfo.swift

[![CI](https://github.com/adam-rocska/VersionInfo.swift/actions/workflows/ci.yml/badge.svg)](https://github.com/adam-rocska/VersionInfo.swift/actions/workflows/ci.yml)
[![Release](https://github.com/adam-rocska/VersionInfo.swift/actions/workflows/release.yml/badge.svg)](https://github.com/adam-rocska/VersionInfo.swift/actions/workflows/release.yml)
[![Swift Package Index](https://img.shields.io/endpoint?url=https://swiftpackageindex.com/api/packages/adam-rocska/VersionInfo.swift/badge?type=swift-versions)](https://swiftpackageindex.com/adam-rocska/VersionInfo.swift)
[![Platforms](https://img.shields.io/endpoint?url=https://swiftpackageindex.com/api/packages/adam-rocska/VersionInfo.swift/badge?type=platforms)](https://swiftpackageindex.com/adam-rocska/VersionInfo.swift)
[![Documentation](https://img.shields.io/badge/DocC-Swift%20Package%20Index-blue)](https://swiftpackageindex.com/adam-rocska/VersionInfo.swift/documentation/versioninfo)

Compile your Swift package's Git identity into the target that needs it.

VersionInfo.swift is a small Swift Package Manager plugin and library for
answering a deceptively annoying question:

> What version of this code is actually running?

Attach the plugin to a target, and SwiftPM generates a tiny Swift file before
that target compiles. Your code then reads a normal `versions` value. No shell
scripts in your app, no runtime `git` calls, no platform-specific build phase.

## Why It Exists

Real Swift projects often need build identity in places where Git is unavailable
or should not be touched:

- command line `--version` output
- server health and diagnostics endpoints
- crash reports and support bundles
- release automation checks
- debug screens in apps
- test fixtures that need to assert the exact built commit

The awkward part is not the data. Git already has the data. The awkward part is
getting it into Swift code in a way that is native to SwiftPM, reusable across
packages, friendly to cross-platform builds, and boring at runtime.

VersionInfo.swift does that by moving the Git lookup to build time and compiling
the result into your target.

## Products

The package ships three products:

- `VersionInfoPlugin`: a SwiftPM build tool plugin that generates `versions`.
- `VersionInfo`: a library with `SemanticVersion` and the shared `Version`
  tuple shape.
- `version-info-gen`: the executable used by the plugin. Most users never call
  it directly.

Use the plugin by itself when you only need Git refs. Add the library when you
also want strict semantic version parsing, comparison, encoding, and decoding.

## Installation

Add VersionInfo.swift to your package dependencies:

```swift
dependencies: [
  .package(
    url: "https://github.com/adam-rocska/VersionInfo.swift.git",
    from: "1.0.0"
  )
]
```

## Quick Start

Attach the plugin to the target that needs build information:

```swift
.executableTarget(
  name: "MyTool",
  plugins: [
    .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
  ]
)
```

Then read `versions` from normal Swift code in that target:

```swift
print("built from \(versions.head.name)")
print("commit \(versions.head.hash)")
```

That is the whole plugin-only path.

You do not import `VersionInfo` for this. The plugin generates source directly
inside the target that declares the plugin.

## What Gets Generated

The plugin generates a Swift file with this shape:

```swift
typealias Version = (name: String, hash: String)
typealias Versions = (head: Version, heads: [Version], tags: [Version])

let versions: Versions
```

For a repository whose `HEAD` points at `main`, `versions.head` might be:

```swift
(name: "main", hash: "1111111111111111111111111111111111111111")
```

The generated value records:

- `versions.head`: the current `HEAD`, either a branch name or detached `HEAD`.
- `versions.heads`: local branch refs found in the repository metadata.
- `versions.tags`: tag refs found in the repository metadata.

## Build Process

`VersionInfoPlugin` is attached to a target in `Package.swift`. SwiftPM invokes
the plugin as part of that target's build plan.

The plugin registers a build tool command. SwiftPM runs that command before it
compiles the target whenever the generated source is needed or one of the
declared Git metadata inputs changes.

The command runs `version-info-gen`, reads the package checkout's `.git`
metadata, and writes a generated `VersionInfo.swift` source file into SwiftPM's
plugin work directory.

SwiftPM then compiles that generated file into the target. From your code's
point of view, `versions` is just another top-level Swift value.

Because the generated file is built into your binary:

- your app does not need Git at runtime
- deployed artifacts keep the build identity they were compiled with
- the plugin can be used without linking the `VersionInfo` library
- changed Git metadata inputs are picked up by SwiftPM's build planning

## Plugin Only

Use this when you only need generated Git refs:

```swift
.target(
  name: "App",
  plugins: [
    .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
  ]
)
```

```swift
let head = versions.head
let tagNames = versions.tags.map(\.name)

print("built from \(head.name) at \(head.hash)")
print("visible tags: \(tagNames)")
```

## Library Only

Use this when you want semantic version behavior without generated Git
information:

```swift
.target(
  name: "App",
  dependencies: [
    .product(name: "VersionInfo", package: "VersionInfo.swift")
  ]
)
```

```swift
import VersionInfo

let current = SemanticVersion("1.2.0")!
let minimum = SemanticVersion("1.1.0")!

print(current > minimum)
```

`SemanticVersion` supports:

- `major.minor.patch`
- prerelease identifiers, such as `1.0.0-rc.1`
- build metadata, such as `1.0.0+build.42`
- `Codable`
- `Comparable`
- `Hashable`
- `RawRepresentable`
- `LosslessStringConvertible`
- `ExpressibleByStringLiteral`
- `Sendable`

## Plugin and Library Together

Use both products when your Git tags are semantic versions and your Swift code
needs to reason about them:

```swift
.target(
  name: "App",
  dependencies: [
    .product(name: "VersionInfo", package: "VersionInfo.swift")
  ],
  plugins: [
    .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
  ]
)
```

```swift
import VersionInfo

let semanticTags = versions.tags.compactMap(SemanticVersion.init)
let latest = semanticTags.max()

if let latest {
  print("latest semantic tag: \(latest)")
}
```

You can also parse a specific generated ref:

```swift
if let tag = versions.tags.first(where: { $0.name == "1.0.0" }),
  let version = SemanticVersion(tag)
{
  print("tag \(version) points at \(tag.hash)")
}
```

## Semantic Version Behavior

`SemanticVersion` follows SemVer precedence rules:

```swift
let prerelease = SemanticVersion("1.0.0-rc.1")!
let release = SemanticVersion("1.0.0")!

print(prerelease < release)
// true
```

Numeric prerelease identifiers are compared numerically without converting them
to `Int`, so very large identifiers compare correctly without overflow.

Build metadata is retained for display, encoding, and decoding, but it is not
part of equality, hashing, or ordering:

```swift
let local = SemanticVersion("1.0.0+local.1")!
let ci = SemanticVersion("1.0.0+ci.2")!

print(local == ci)
// true
```

That mirrors SemVer precedence: build metadata describes a build, not a
different release version.

## Git Repository Shapes

The generator reads Git metadata directly from files. It supports the checkout
shapes commonly produced by Git:

- loose refs in `.git/refs/heads` and `.git/refs/tags`
- packed refs in `.git/packed-refs`
- `.git` files containing `gitdir: ...`
- symbolic `HEAD`
- detached `HEAD`
- nested branch and tag names

## Platform Support

VersionInfo.swift uses Swift tools version 6.0.

The public `VersionInfo` library and the generated Swift source use Swift
language and standard library features only. They are intended for:

- Apple platforms declared in `Package.swift`: macOS 14, iOS 16, watchOS 9,
  tvOS 17, and visionOS 1
- Linux for server-side Swift
- Android through the official Swift Android SDK
- WebAssembly/WASI through the official Swift Wasm SDK

The plugin and `version-info-gen` executable run on the build host. They use
SwiftPM, Foundation file APIs, and a filesystem-backed Git checkout. When
cross-compiling, the host toolchain runs the plugin and the target SDK compiles
your target.

For 1.0.0 release confidence, macOS and Linux builds/tests should pass, and the
library target should be cross-built with the official Android and Wasm Swift
SDKs before tagging.

## Command Line Generator

Most users should use the plugin. The executable product is public because the
plugin needs it, and it can be useful for debugging:

```sh
swift run version-info-gen .git
```

To write the generated Swift file to a directory:

```sh
swift run version-info-gen .git --output-dir Generated
```

## Documentation

DocC documentation is included in the `VersionInfo` target. It covers:

- adding the plugin to a target
- how SwiftPM includes the generated source
- the generated `versions` API
- semantic version parsing and comparison
- cross-platform expectations
- the design choices behind the tuple bridge

Generate or preview the docs with SwiftPM:

```sh
swift package generate-documentation --target VersionInfo
swift package --disable-sandbox preview-documentation --target VersionInfo
```

## Quality

The package is tested with Swift Testing. The suite covers:

- unit behavior for semantic versions and Git ref parsing
- integration behavior for the command line generator
- user acceptance flows with temporary consumer packages
- plugin behavior across loose refs, packed refs, `.git` files, detached `HEAD`,
  nested ref names, and regenerated Git metadata

For local confidence, run:

```sh
swift test
swift test -c release
swift test --enable-code-coverage
```

Linux CI is configured with official Swift Docker images for Swift 6.0, 6.1,
and 6.2. Android and Wasm should be verified with official Swift SDKs by
building the `VersionInfo` library target before tagging 1.0.0:

```sh
swift sdk list
swift build --swift-sdk <android-sdk-id> --target VersionInfo
swift build --swift-sdk <wasm-sdk-id> --target VersionInfo
```

## License

VersionInfo.swift is released under the MIT License. See `LICENSE`.
