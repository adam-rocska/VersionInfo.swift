# Cross-Platform Support

Understand which part runs on the build host and which part ships with your
target.

## Library and Generated Source

The public `VersionInfo` library and the generated Swift source use Swift
language and standard library features only.

They are intended for Swift packages targeting:

- Apple platforms declared in `Package.swift`
- Linux
- Android through the official Swift Android SDK
- WebAssembly/WASI through the official Swift Wasm SDK

## Plugin and Generator

`VersionInfoPlugin` and `version-info-gen` run on the build host.

They use:

- Swift Package Manager's plugin API
- Foundation file APIs
- a filesystem-backed Git checkout

When cross-compiling, the host SwiftPM toolchain runs the plugin and generator.
The target SDK then compiles your package, including the generated Swift source.

## Practical Release Check

Before tagging a release, verify the native platforms you publish for:

```sh
swift test
swift test -c release
```

Then verify cross-compilation with the official Swift SDKs you care about:

```sh
swift sdk list
swift build --swift-sdk <android-sdk-id> --target VersionInfo
swift build --swift-sdk <wasm-sdk-id> --target VersionInfo
```

The plugin does not add a runtime Git dependency to any target platform.
