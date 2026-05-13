import Foundation

public final class TemporaryDirectory: @unchecked Sendable {
  public let url: URL

  public init(prefix: String = "VersionInfoTests") throws {
    url = FileManager.default.temporaryDirectory
      .appendingPathComponent("\(prefix)-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  }

  deinit {
    try? FileManager.default.removeItem(at: url)
  }

  public func appending(_ components: String...) -> URL {
    components.reduce(url) { partial, component in
      partial.appendingPathComponent(component)
    }
  }

  public func createDirectory(_ components: String...) throws -> URL {
    let directory = appending(components)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }

  public func write(_ contents: String, to components: String...) throws -> URL {
    let file = appending(components)
    try FileManager.default.createDirectory(
      at: file.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try contents.write(to: file, atomically: true, encoding: .utf8)
    return file
  }
}

extension TemporaryDirectory {
  private func appending(_ components: [String]) -> URL {
    components.reduce(url) { partial, component in
      partial.appendingPathComponent(component)
    }
  }
}
