import Foundation

struct GitDirectory {
  let root: URL

  private func files(in directory: URL) -> [URL] {
    (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil))
      ?? []
  }

  var head: URL { root.appending(component: "HEAD") }
  var heads: [URL] { files(in: root.appending(component: "refs/heads")) }
  var tags: [URL] { files(in: root.appending(component: "refs/tags")) }

}
