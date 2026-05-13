import Foundation

public struct ProcessResult: Sendable {
  public let executable: String
  public let arguments: [String]
  public let exitCode: Int32
  public let stdout: String
  public let stderr: String

  public var commandLine: String {
    ([executable] + arguments).joined(separator: " ")
  }
}

public struct ProcessFailure: Error, CustomStringConvertible, Sendable {
  public let result: ProcessResult

  public var description: String {
    """
    Command failed with exit code \(result.exitCode):
    \(result.commandLine)

    stdout:
    \(result.stdout)

    stderr:
    \(result.stderr)
    """
  }
}

public enum ProcessRunner {
  @discardableResult
  public static func run(
    _ executable: URL,
    arguments: [String],
    currentDirectory: URL? = nil,
    environment: [String: String] = [:]
  ) throws -> ProcessResult {
    let temporaryDirectory = try TemporaryDirectory(prefix: "VersionInfoProcess")
    let stdoutURL = temporaryDirectory.appending("stdout.txt")
    let stderrURL = temporaryDirectory.appending("stderr.txt")

    _ = FileManager.default.createFile(atPath: stdoutURL.path, contents: nil)
    _ = FileManager.default.createFile(atPath: stderrURL.path, contents: nil)

    let stdout = try FileHandle(forWritingTo: stdoutURL)
    let stderr = try FileHandle(forWritingTo: stderrURL)
    defer {
      try? stdout.close()
      try? stderr.close()
    }

    let process = Process()
    process.executableURL = executable
    process.arguments = arguments
    process.currentDirectoryURL = currentDirectory
    process.standardOutput = stdout
    process.standardError = stderr

    var processEnvironment = ProcessInfo.processInfo.environment
    environment.forEach { key, value in
      processEnvironment[key] = value
    }
    process.environment = processEnvironment

    try process.run()
    process.waitUntilExit()

    let output = try String(contentsOf: stdoutURL, encoding: .utf8)
    let error = try String(contentsOf: stderrURL, encoding: .utf8)

    return ProcessResult(
      executable: executable.path,
      arguments: arguments,
      exitCode: process.terminationStatus,
      stdout: output,
      stderr: error
    )
  }

  @discardableResult
  public static func requireSuccess(
    _ executable: URL,
    arguments: [String],
    currentDirectory: URL? = nil,
    environment: [String: String] = [:]
  ) throws -> ProcessResult {
    let result = try run(
      executable,
      arguments: arguments,
      currentDirectory: currentDirectory,
      environment: environment
    )
    guard result.exitCode == 0 else {
      throw ProcessFailure(result: result)
    }
    return result
  }
}
