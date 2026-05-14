# Generated Version Information

Understand what the build tool plugin generates and how to use it.

## The Generated API

`VersionInfoPlugin` generates this shape in the consuming target:

```swift
typealias Version = (name: String, hash: String)
typealias Versions = (head: Version, heads: [Version], tags: [Version])

let versions: Versions
```

`versions.head` describes the current `HEAD`. It is a branch name when `HEAD` is
symbolic, or `"HEAD"` when the repository is detached.

`versions.heads` contains branch refs.

`versions.tags` contains tag refs.

## Example

```swift
let head = versions.head

print("branch or checkout: \(head.name)")
print("commit: \(head.hash)")
```

To print semantic tags:

```swift
for tag in versions.tags {
  guard let version = SemanticVersion(tag) else { continue }
  print("\(version) at \(tag.hash)")
}
```

## Repository Shapes

The generator reads Git metadata directly. It supports:

- loose refs
- packed refs
- `.git` files with `gitdir: ...`
- symbolic `HEAD`
- detached `HEAD`
- nested branch and tag names

The generated Swift file contains the resolved values. Your application does not
need Git at runtime.

## Why a Tuple?

``Version`` is intentionally a tuple:

```swift
public typealias Version = (name: String, hash: String)
```

The plugin-only use case should not require linking a runtime library. The
library exposes the same tuple shape so generated refs can still be used as
semantic version input when the library is present.
