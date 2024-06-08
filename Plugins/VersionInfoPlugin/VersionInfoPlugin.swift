import Foundation
import PackagePlugin

@main
struct VersionInfoPlugin: BuildToolPlugin {
  enum Error: Swift.Error, CustomStringConvertible {
    case noGitDirectory(in: Path)

    var description: String {
      switch self {
      case let .noGitDirectory(path):
        return "No .git directory found in \(path)."
      }
    }
  }

  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    guard let gitDirectory = URL(string: context.package.directory.appending(".git").string) else {
      throw Error.noGitDirectory(in: context.package.directory)
    }

    let outputDir = context.pluginWorkDirectory.appending("VersionInfoGenerated")
    try FileManager.default.createDirectory(
      atPath: outputDir.string,
      withIntermediateDirectories: true)

    return [
      .buildCommand(
        displayName: "Running version-info-gen",
        executable: try context.tool(named: "version-info-gen").path,
        arguments: [gitDirectory, "--output-dir", outputDir],
        outputFiles: [
          outputDir.appending("VersionInfo.swift")
        ]
      )
    ]
  }
}
