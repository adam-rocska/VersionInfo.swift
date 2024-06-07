// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "VersionInfo",
  products: [
    .library(
      name: "VersionInfo",
      targets: ["VersionInfo"]
    )
  ],
  targets: [
    .target(
      name: "VersionInfo"),
    .testTarget(
      name: "VersionInfoTests",
      dependencies: ["VersionInfo"]),
  ]
)
