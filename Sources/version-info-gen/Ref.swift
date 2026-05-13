import Foundation

struct Ref {
  let name: String
  let hash: String

  init(name: String, hash: String) {
    self.name = name
    self.hash = hash
  }

  init?(file: URL) {
    self.init(file: file, name: file.refName ?? file.lastPathComponent)
  }

  init?(file: URL, relativeTo directory: URL) {
    guard let name = file.path(relativeTo: directory) else { return nil }
    self.init(file: file, name: name)
  }

  private init?(file: URL, name: String) {
    guard let hash = Self.hash(in: file) else { return nil }

    self.init(
      name: name,
      hash: hash
    )
  }

  init?(HEAD: URL) {
    guard let contents = try? String(contentsOf: HEAD) else { return nil }
    let head = contents.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !head.isEmpty else { return nil }

    if let symbolicPath = head.symbolicRefPath {
      let ref = HEAD.deletingLastPathComponent().appendingGitPath(symbolicPath)
      self.init(file: ref, name: symbolicPath.refName)
    } else {
      self.init(name: "HEAD", hash: head)
    }
  }

  private static func hash(in file: URL) -> String? {
    guard let contents = try? String(contentsOf: file) else { return nil }
    let hash = contents.trimmingCharacters(in: .whitespacesAndNewlines)
    return hash.isEmpty ? nil : hash
  }
}

extension URL {
  fileprivate var refName: String? {
    guard let refsIndex = pathComponents.lastIndex(of: "refs") else {
      return nil
    }

    let refComponents = pathComponents.dropFirst(refsIndex + 2)
    guard !refComponents.isEmpty else { return nil }
    return refComponents.joined(separator: "/")
  }

  fileprivate func path(relativeTo directory: URL) -> String? {
    let base = directory.standardizedFileURL.pathComponents
    let path = standardizedFileURL.pathComponents

    guard path.starts(with: base) else { return nil }
    let relative = path.dropFirst(base.count)
    guard !relative.isEmpty else { return nil }
    return relative.joined(separator: "/")
  }

  fileprivate func appendingGitPath(_ path: String) -> URL {
    path.split(separator: "/").reduce(self) { url, component in
      url.appendingPathComponent(String(component))
    }
  }
}

extension String {
  fileprivate var symbolicRefPath: String? {
    guard hasPrefix("ref:") else { return nil }
    let path = dropFirst("ref:".count).trimmingCharacters(in: .whitespacesAndNewlines)
    return path.isEmpty ? nil : path
  }

  fileprivate var refName: String {
    if hasPrefix("refs/heads/") {
      return String(dropFirst("refs/heads/".count))
    }
    if hasPrefix("refs/tags/") {
      return String(dropFirst("refs/tags/".count))
    }
    return self
  }
}
