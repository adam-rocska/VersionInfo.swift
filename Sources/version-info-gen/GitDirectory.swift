import Foundation

struct GitDirectory {
  let root: URL

  private func refFiles(in directory: URL) -> [URL] {
    FileManager.default
      .enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey]
      )?
      .compactMap { $0 as? URL }
      .filter(\.isRegularFile)
      .sorted { $0.path < $1.path } ?? []
  }

  var head: URL { root.appendingPathComponent("HEAD") }
  var headsDirectory: URL { root.appendingPathComponent("refs/heads", isDirectory: true) }
  var tagsDirectory: URL { root.appendingPathComponent("refs/tags", isDirectory: true) }
  var heads: [URL] { refFiles(in: headsDirectory) }
  var tags: [URL] { refFiles(in: tagsDirectory) }

}

extension URL {
  fileprivate var isRegularFile: Bool {
    (try? resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
  }
}
