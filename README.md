# VersionInfo.swift

VersionInfo.swift gives Swift packages build-time access to their own Git
version information.

It ships two pieces that can be used separately or together:

- `VersionInfoPlugin`, a Swift Package Manager build tool plugin that generates
  a small Swift file in your target at build time.
- `VersionInfo`, a tiny library for working with semantic versions and the
  generated Git ref tuples.

The plugin does not call `git` at runtime. It reads the repository metadata at
build time and compiles the result into your binary.

## What Problem Does It Solve?

Applications often need to answer simple questions:

- What commit was this binary built from?
- What branch or tag was visible at build time?
- Is the current tag a valid semantic version?
- How does this version compare with another release?

You can solve those questions with shell scripts, environment variables, custom
build phases, or runtime calls to `git`. Those approaches tend to be fragile,
platform-specific, or hard to reuse across Swift packages.

VersionInfo.swift keeps the workflow native to Swift Package Manager:

1. Add a package dependency.
2. Attach a build tool plugin to a target.
3. Use the generated `versions` value from normal Swift code.

## Platform Support

- Swift tools version 6.0 or newer.
- Swift Package Manager.
- A package checkout with a `.git` directory or `.git` file.

The package is designed for cross-platform Swift projects:

- Apple platforms declared in `Package.swift`: macOS 14, iOS 16, watchOS 9,
  tvOS 17, and visionOS 1.
- Linux for server-side Swift.
- Android and WebAssembly/WASI through Swift SDK cross-compilation.

The public `VersionInfo` library and the generated Swift source are
Foundation-free and use only Swift language and standard library features. The
build tool plugin and `version-info-gen` executable run on the build host and
use SwiftPM, Foundation file APIs, and a filesystem-backed Git checkout.

For 1.0.0 release confidence, macOS and Linux builds/tests should pass, and the
library target should be cross-built with the official Android and Wasm Swift
SDKs before tagging.

## Installation

Add VersionInfo.swift to your package dependencies:

```swift
dependencies: [
  .package(
    url: "https://github.com/adam-rocska/VersionInfo.swift",
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

Then use the generated `versions` value from that target:

```swift
print(versions.head.name)
print(versions.head.hash)
```

The generated value has this shape:

```swift
typealias Version = (name: String, hash: String)
typealias Versions = (head: Version, heads: [Version], tags: [Version])

let versions: Versions
```

For a repository whose `HEAD` points at `main`, `versions.head` might look like
this:

```swift
(name: "main", hash: "1111111111111111111111111111111111111111")
```

## Using the Plugin Only

Use this when you only need the generated Git refs and do not need semantic
version parsing.

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
let tags = versions.tags.map(\.name)

print("built from \(head.name) at \(head.hash)")
print("visible tags: \(tags)")
```

The plugin records:

- `versions.head`: the current `HEAD`, either a branch name or detached `HEAD`.
- `versions.heads`: local branch refs found in the repository metadata.
- `versions.tags`: tag refs found in the repository metadata.

## Using the Library Only

Use this when you want semantic version parsing and comparison without generated
Git information.

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

let current = SemanticVersion("1.2.0")
let minimum = SemanticVersion("1.1.0")

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

## Using the Plugin and Library Together

Use both products when your Git tags are semantic versions and your code needs
to reason about them.

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

let releaseTags = versions.tags.compactMap(SemanticVersion.init)
let latest = releaseTags.max()

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

`SemanticVersion` follows SemVer precedence rules for ordering:

```swift
let prerelease = SemanticVersion("1.0.0-rc.1")!
let release = SemanticVersion("1.0.0")!

print(prerelease < release)
// true
```

Numeric prerelease identifiers are compared numerically without converting them
to `Int`, so very large identifiers compare correctly without overflow.

Build metadata is retained for display, encoding, and decoding, but it is not
part of version precedence:

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

No runtime Git dependency is introduced into your application.

## Command Line Generator

The executable product is mostly used by the plugin, but it can be run directly:

```sh
swift run version-info-gen .git
```

To write the generated Swift file to a directory:

```sh
swift run version-info-gen .git --output-dir Generated
```

## Documentation

DocC documentation is included in the `VersionInfo` target. It covers:

- getting started with the build tool plugin
- the generated `versions` API
- semantic version parsing and comparison
- the design choices behind the tuple bridge and build metadata behavior

## Design Notes

`Version` is intentionally a tuple:

```swift
public typealias Version = (name: String, hash: String)
```

The generated code uses the same shape. This keeps plugin-only users free from
any runtime library dependency, while library users can still pass generated
refs directly to `SemanticVersion`.

The plugin output is static Swift source. Once your target is built, reading
`versions.head` is just reading a compiled value.

## Quality

The package is tested with Swift Testing. The suite covers:

- unit behavior for semantic versions and Git ref parsing
- integration behavior for the command line generator
- user acceptance flows with temporary consumer packages
- plugin behavior across loose refs, packed refs, `.git` files, detached `HEAD`,
  and nested ref names

For release confidence, run:

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
