import Foundation

public struct SwiftPM: Sendable {
  public let workingDirectory: URL
  public let scratchPath: URL
  public let cachePath: URL
  public let configPath: URL
  public let securityPath: URL

  public init(workingDirectory: URL, stateDirectory: URL? = nil) throws {
    self.workingDirectory = workingDirectory

    let supportDirectory = stateDirectory
      ?? FileManager.default.temporaryDirectory
        .appendingPathComponent("VersionInfoSwiftPM-\(UUID().uuidString)", isDirectory: true)
    scratchPath = supportDirectory.appendingPathComponent("scratch", isDirectory: true)
    cachePath = supportDirectory.appendingPathComponent("cache", isDirectory: true)
    configPath = supportDirectory.appendingPathComponent("config", isDirectory: true)
    securityPath = supportDirectory.appendingPathComponent("security", isDirectory: true)

    try [scratchPath, cachePath, configPath, securityPath].forEach {
      try FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true)
    }
  }

  public func run(_ arguments: [String]) throws -> ProcessResult {
    try ProcessRunner.requireSuccess(
      PackagePaths.swiftExecutable,
      arguments: scoped(arguments),
      currentDirectory: workingDirectory
    )
  }

  public func runAllowingFailure(_ arguments: [String]) throws -> ProcessResult {
    try ProcessRunner.run(
      PackagePaths.swiftExecutable,
      arguments: scoped(arguments),
      currentDirectory: workingDirectory
    )
  }

  private func scoped(_ arguments: [String]) -> [String] {
    guard let command = arguments.first else { return scopedArguments }
    return [command] + scopedArguments + arguments.dropFirst()
  }

  private var scopedArguments: [String] {
    [
      "--scratch-path", scratchPath.path,
      "--cache-path", cachePath.path,
      "--config-path", configPath.path,
      "--security-path", securityPath.path,
    ]
  }
}
