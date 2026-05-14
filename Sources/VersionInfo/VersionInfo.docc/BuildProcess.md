# Build Process

Understand how the SwiftPM plugin becomes usable Swift code.

## Target Attachment

The plugin is attached in `Package.swift`:

```swift
.target(
  name: "App",
  plugins: [
    .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
  ]
)
```

This attaches the plugin to `App`. It does not attach it to every target in the
package, and it does not require `import VersionInfo`.

Only targets that declare the plugin receive the generated `versions` value.

## Build Tool Generation

`VersionInfoPlugin` registers a SwiftPM build tool command.

Before SwiftPM compiles the target, the command runs `version-info-gen` with the
package checkout's `.git` path whenever the generated source is needed or one
of the declared Git metadata inputs changes. The generator resolves `HEAD`,
local branches, and tags, then writes a generated Swift file into SwiftPM's
plugin work directory.

SwiftPM includes that generated file as source for the target.

## Result

Your target can use:

```swift
versions.head
versions.heads
versions.tags
```

The values are compiled into the binary. Runtime code does not need:

- a `.git` directory
- the `git` executable
- environment variables
- a custom build phase

## Freshness

Git refs are not Swift source files, so the plugin tells SwiftPM which visible
Git metadata files matter for generation.

The declared inputs include:

- `.git` files that point at another Git directory
- `HEAD`
- `packed-refs`
- loose branch refs
- loose tag refs

When one of those files changes, SwiftPM refreshes the generated source before
compiling the target.
