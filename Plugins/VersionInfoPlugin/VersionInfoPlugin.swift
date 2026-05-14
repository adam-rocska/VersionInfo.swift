import Foundation
import PackagePlugin

@main
struct VersionInfoPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    let gitDirectory = context.package.directoryURL.appendingPathComponent(".git", isDirectory: true)
    let outputDir = context.pluginWorkDirectoryURL.appendingPathComponent("VersionInfoGenerated", isDirectory: true)

    return [
      .buildCommand(
        displayName: "Running version-info-gen",
        executable: try context.tool(named: "version-info-gen").url,
        arguments: [gitDirectory.path, "--output-dir", outputDir.path],
        inputFiles: gitDirectory.gitMetadataInputFiles,
        outputFiles: [
          outputDir.appendingPathComponent("VersionInfo.swift")
        ]
      )
    ]
  }
}

extension URL {
  fileprivate var gitMetadataInputFiles: [URL] {
    let gitDirectory = resolvedGitDirectory ?? self

    return (
      [self] + [
        gitDirectory.appendingPathComponent("HEAD"),
        gitDirectory.appendingPathComponent("packed-refs"),
      ] + gitDirectory.refInputFiles(in: "refs/heads")
        + gitDirectory.refInputFiles(in: "refs/tags")
    )
    .filter(\.isRegularFile)
  }

  fileprivate func refInputFiles(in path: String) -> [URL] {
    let directory = appendingPathComponent(path, isDirectory: true)

    return FileManager.default
      .enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey]
      )?
      .compactMap { $0 as? URL }
      .filter(\.isRegularFile)
      .sorted { $0.path < $1.path } ?? []
  }

  fileprivate var isRegularFile: Bool {
    (try? resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
  }

  fileprivate var resolvedGitDirectory: URL? {
    guard let contents = try? String(contentsOf: self) else { return nil }

    let gitdir = contents.trimmingCharacters(in: .whitespacesAndNewlines)
    guard gitdir.hasPrefix("gitdir:") else { return nil }

    let path = gitdir
      .dropFirst("gitdir:".count)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard !path.isEmpty else { return nil }

    return URL(
      fileURLWithPath: path,
      relativeTo: deletingLastPathComponent()
    )
    .standardizedFileURL
  }
}
