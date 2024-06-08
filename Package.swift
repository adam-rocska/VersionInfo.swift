// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "VersionInfo.swift",
  platforms: [.macOS(.v14), .iOS(.v16), .watchOS(.v9), .tvOS(.v17), .visionOS(.v1)],
  products: [
    .plugin(name: "VersionInfoPlugin", targets: ["VersionInfoPlugin"]),
    .library(name: "VersionInfo", targets: ["VersionInfo"]),
    .executable(name: "version-info-gen", targets: ["version-info-gen"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0")
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
  ]
)
