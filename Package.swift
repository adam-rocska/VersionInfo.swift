// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "VersionInfo.swift",
  platforms: [
    .macOS(.v14), .iOS(.v16), .watchOS(.v9), .tvOS(.v17), .visionOS(.v1),
  ],
  products: [
    .plugin(name: "VersionInfoPlugin", targets: ["VersionInfoPlugin"]),
    .library(name: "VersionInfo", targets: ["VersionInfo"]),
    .executable(name: "version-info-gen", targets: ["version-info-gen"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser.git",
      from: "1.4.0"
    ),
    .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
  ],
  targets: [
    .target(name: "VersionInfo"),
    .plugin(
      name: "VersionInfoPlugin",
      capability: .buildTool,
      dependencies: ["version-info-gen"]
    ),
    .executableTarget(
      name: "version-info-gen",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .target(
      name: "VersionInfoTestSupport",
      path: "Tests/Support"
    ),
    .testTarget(
      name: "VersionInfoTests",
      dependencies: ["VersionInfo", "VersionInfoTestSupport"],
      path: "Tests/Unit/VersionInfoTests"
    ),
    .testTarget(
      name: "VersionInfoGenTests",
      dependencies: ["version-info-gen", "VersionInfoTestSupport"],
      path: "Tests/Unit/VersionInfoGenTests"
    ),
    .testTarget(
      name: "VersionInfoIntegrationTests",
      dependencies: ["VersionInfoTestSupport"],
      path: "Tests/Regression/VersionInfoIntegrationTests"
    ),
    .testTarget(
      name: "VersionInfoUserAcceptanceTests",
      dependencies: ["VersionInfoTestSupport"],
      path: "Tests/UserAcceptance/VersionInfoUserAcceptanceTests"
    ),
  ]
)
