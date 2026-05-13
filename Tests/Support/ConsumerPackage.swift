import Foundation

public struct ConsumerPackage: Sendable {
  public let directory: URL
  public let executableName: String

  public static func create(
    in directory: URL,
    name: String,
    dependencies: String,
    targetDependencies: String,
    plugins: String,
    main: String
  ) throws -> ConsumerPackage {
    let sourceDirectory = directory
      .appendingPathComponent("Sources", isDirectory: true)
      .appendingPathComponent(name, isDirectory: true)
    try FileManager.default.createDirectory(at: sourceDirectory, withIntermediateDirectories: true)

    try packageManifest(
      name: name,
      packageRoot: PackagePaths.root.path,
      dependencies: dependencies,
      targetDependencies: targetDependencies,
      plugins: plugins
    ).write(
      to: directory.appendingPathComponent("Package.swift"),
      atomically: true,
      encoding: .utf8
    )

    try main.write(
      to: sourceDirectory.appendingPathComponent("main.swift"),
      atomically: true,
      encoding: .utf8
    )

    return ConsumerPackage(directory: directory, executableName: name)
  }

  private static func packageManifest(
    name: String,
    packageRoot: String,
    dependencies: String,
    targetDependencies: String,
    plugins: String
  ) -> String {
    """
    // swift-tools-version: 6.0

    import PackageDescription

    let package = Package(
      name: "\(name)",
      platforms: [.macOS(.v14)],
      dependencies: [
        .package(path: \(String(reflecting: packageRoot)))
      ],
      targets: [
        .executableTarget(
          name: "\(name)",
          dependencies: [
            \(dependencies)
            \(targetDependencies)
          ],
          plugins: [
            \(plugins)
          ]
        )
      ]
    )
    """
  }
}
