# Why VersionInfo.swift

Understand the problem this package solves and why it solves it at build time.

## The Small Question That Keeps Coming Back

Many Swift programs eventually need to print, expose, or record their own build
identity:

```swift
print("Version \(version), commit \(commit)")
```

The hard part is deciding where `version` and `commit` come from.

Runtime Git calls work on a development machine, then fail in a container,
mobile app, release bundle, stripped deployment artifact, or CI environment that
does not ship `.git`.

Custom shell scripts work until the package moves, the target changes, a new
platform appears, or another package needs the same behavior.

Environment variables work until they are forgotten in one build path.

VersionInfo.swift keeps this inside SwiftPM.

## The Build-Time Move

The plugin reads Git metadata while SwiftPM is already building the package.
Then it emits Swift source and SwiftPM compiles that source into the target.

After that, reading build identity is just reading a value:

```swift
versions.head.hash
```

That is the important trick. Git is a build input, not a runtime dependency.

## Why It Matters

Compiled-in version information is useful anywhere a program needs to explain
itself:

- command line `--version` output
- server health endpoints
- diagnostics and support bundles
- crash reports
- release checks
- debug screens
- reproducibility audits

The package stays small because it does one job in two layers:

- the plugin gets Git refs into Swift code
- the library helps interpret semantic version tags

Use one layer or both, depending on the target.
