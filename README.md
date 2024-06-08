# VersionInfo

Swift VersionInfo is a Swift Package shipping a Swift
library, and a Swift Package Manager Plugin, enabling its
users to statically access their library's or executable's
version info, compiled in their binary without runtime
aspects and without any headaches.

Swift VersionInfo is designed to be used in both server-side
and classical Swift GUI applications, and should be
compatible with all platforms Swift supports.

## Features

- Static access to version information.
- Works with both server-side and GUI applications.
- Compatible with all platforms supported by Swift.

## Installation

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/adam-rocska/VersionInfo.swift", from: "1.0.0")
]
```

## Usage

### Just the Swift Package Manager Plugin

Add the following to your relevant target:

  ```swift
  plugins: [
        .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
      ]
  ```

Then just simply use it in your code as such:

```swift

  print(versions.head)
// Prints: (name: "master", hash: "0f83992bc09b82a2627c48a71551e2ba633c8d03")

  ```

### Just the Swift Library

Add the following to your relevant target:

  ```swift
  dependencies: [
        .product(name: "VersionInfo", package: "VersionInfo.swift")
      ]
  ```

Then just simply use it in your code as such:

```swift
import VersionInfo

let currentVersion = SemanticVersion("1.1.0")
let previousVersion = SemanticVersion("1.0.0")

print(currentVersion > previousVersion)
// Prints: true

```

### Both the Swift Package Manager Plugin and the Swift Library

It is of intentional design that the type `Version` is a
tuple. This allows a seamless bridge between the stand-alone
generated code and the library itself.

Add the following to your relevant target:

  ```swift
  dependencies: [
        .product(name: "VersionInfo", package: "VersionInfo.swift")
      ],
  plugins: [
        .plugin(name: "VersionInfoPlugin", package: "VersionInfo.swift")
      ]
  ```

Then just simply use it in your code as such:

```swift

import VersionInfo

print(versions.head)
// Prints: (name: "1.0.0", hash: "0f83992bc09b82a2627c48a71551e2ba633c8d03")
if let version = SemanticVersion(versions.head) {
    print(version)
    // Prints: 1.0.0
    print(version < "1.1.0")
    // Prints: true
}

```
