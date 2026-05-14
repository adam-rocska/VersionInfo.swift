# 1.0.0 Release

VersionInfo.swift 1.0.0 is the first stable release of the package.

## Release Goal

Ship a small, native Swift package that lets Swift targets compile their Git
version information into the binary and optionally reason about semantic
versions through a focused library API.

## Release Notes

### Highlights

- Swift Package Manager build tool plugin for generated Git version info.
- Static `versions` value with `head`, `heads`, and `tags`.
- Support for loose refs, packed refs, `.git` file indirection, symbolic
  `HEAD`, detached `HEAD`, and nested refs.
- `SemanticVersion` with prerelease and build metadata support.
- Swift 6-friendly API with `Sendable` and Swift Testing coverage.
- DocC documentation and a complete README for first-time users.

### Public Products

- `VersionInfoPlugin`
- `VersionInfo`
- `version-info-gen`

### Public Library API

- `Version`
- `SemanticVersion`
- `SemanticVersion.isCompatible(with:)`

## Preflight Checklist

- [ ] Confirm the worktree is clean.
- [ ] Confirm `Package.swift` still declares `swift-tools-version: 6.0`.
- [ ] Run `swift test`.
- [ ] Run `swift test -c release`.
- [ ] Run `swift test --enable-code-coverage`.
- [ ] Confirm the Linux CI matrix passes.
- [ ] Cross-build the `VersionInfo` library target for Android.
- [ ] Cross-build the `VersionInfo` library target for WebAssembly/WASI.
- [ ] Build generated documentation if your local toolchain supports it.
- [ ] Review `README.md`.
- [ ] Review `CHANGELOG.md`.
- [ ] Review this release note.

## Suggested Verification Commands

```sh
git status --short
swift test
swift test -c release
swift test --enable-code-coverage
```

Linux CI is configured for Swift 6.0, 6.1, and 6.2 using the official Swift
Docker images.

For Android and Wasm, install the official Swift SDKs for the active toolchain,
then build the library target:

```sh
swift sdk list
swift build --swift-sdk <android-sdk-id> --target VersionInfo
swift build --swift-sdk <wasm-sdk-id> --target VersionInfo
```

If available in the installed toolchain:

```sh
swift package generate-documentation --target VersionInfo
```

## Tagging

Use a SemVer tag without a prefix:

```sh
git tag 1.0.0
git push origin 1.0.0
```

## Swift Package Index Notes

This release is prepared for Swift Package Index with:

- Swift tools version 6.0.
- A documented library product.
- A documented plugin product.
- Test coverage for plugin behavior through consumer-package acceptance tests.
- DocC content under the `VersionInfo` target.

Before tagging, Linux test results and Android/Wasm cross-build results should
be captured in CI or release notes.
