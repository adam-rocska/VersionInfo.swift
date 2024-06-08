import Foundation

struct Ref {
  let name: String
  let hash: String

  init(name: String, hash: String) {
    self.name = name
    self.hash = hash
  }

  init?(file: URL) {
    guard let hash = try? String(contentsOf: file) else { return nil }
    self.init(
      name: file.lastPathComponent,
      hash: hash.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }

  init?(HEAD: URL) {
    guard let contents = try? String(contentsOf: HEAD) else { return nil }
    let path = contents.trimmingPrefix("ref:").trimmingCharacters(in: .whitespacesAndNewlines)
    guard let referenced = URL(string: path, relativeTo: HEAD.deletingLastPathComponent()) else {
      return nil
    }
    self.init(file: referenced)
  }
}
