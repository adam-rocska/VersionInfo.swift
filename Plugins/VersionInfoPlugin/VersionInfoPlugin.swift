import Foundation
import PackagePlugin

@main
struct VersionInfoPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    let gitDirectory = context.package.directoryURL.appendingPathComponent(".git", isDirectory: true)

    let outputDir = context.pluginWorkDirectoryURL.appendingPathComponent("VersionInfoGenerated", isDirectory: true)
    try FileManager.default.createDirectory(
      at: outputDir,
      withIntermediateDirectories: true)

    return [
      .buildCommand(
        displayName: "Running version-info-gen",
        executable: try context.tool(named: "version-info-gen").url,
        arguments: [gitDirectory.path, "--output-dir", outputDir.path],
        outputFiles: [
          outputDir.appendingPathComponent("VersionInfo.swift")
        ]
      )
    ]
  }
}
