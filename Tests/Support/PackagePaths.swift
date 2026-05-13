import Foundation

public enum PackagePaths {
  public static let root: URL = {
    var directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let fileManager = FileManager.default

    while directory.path != "/" {
      let manifest = directory.appendingPathComponent("Package.swift")
      let sources = directory.appendingPathComponent("Sources", isDirectory: true)
      if fileManager.fileExists(atPath: manifest.path),
        fileManager.fileExists(atPath: sources.path)
      {
        return directory
      }
      directory.deleteLastPathComponent()
    }

    preconditionFailure("Could not find package root from \(#filePath)")
  }()

  public static var swiftExecutable: URL {
    if let swiftExec = ProcessInfo.processInfo.environment["SWIFT_EXEC"] {
      return URL(fileURLWithPath: swiftExec)
    }
    return URL(fileURLWithPath: "/usr/bin/swift")
  }
}
