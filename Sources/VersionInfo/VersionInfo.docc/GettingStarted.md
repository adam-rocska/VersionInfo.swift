# Getting Started

Add build-time version information to a Swift package target.

## Add the Dependency

Add VersionInfo.swift to your package dependencies:

```swift
dependencies: [
  .package(
    url: "https://github.com/adam-rocska/VersionInfo.swift",
    from: "1.0.0"
  )
]
```

## Attach the Plugin

Attach `VersionInfoPlugin` to the target that needs build information:

```swift
.executableTarget(
  name: "MyTool",
  plugins: [
    .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
  ]
)
```

The plugin generates a Swift source file for that target. The file contains a
top-level `versions` value.

## Use the Generated Value

Read `versions` from normal Swift code in the target:

```swift
print("built from \(versions.head.name)")
print("commit \(versions.head.hash)")
```

The generated value is static Swift source. Once the target is built, no runtime
Git lookup is needed.

## Add the Library When Needed

If you also want semantic version parsing, add the library product:

```swift
.executableTarget(
  name: "MyTool",
  dependencies: [
    .product(name: "VersionInfo", package: "VersionInfo.swift")
  ],
  plugins: [
    .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
  ]
)
```

Then parse generated tags:

```swift
import VersionInfo

let semanticTags = versions.tags.compactMap(SemanticVersion.init)
let latest = semanticTags.max()
```
