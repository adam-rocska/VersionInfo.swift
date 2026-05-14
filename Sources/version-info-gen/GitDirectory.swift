import Foundation

struct GitDirectory {
  let root: URL

  init(root: URL) {
    self.root = root.resolvedGitDirectory ?? root
  }

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
  var headRef: Ref? { Ref(HEAD: head) ?? packedHeadRef }
  var headsDirectory: URL { root.appendingPathComponent("refs/heads", isDirectory: true) }
  var tagsDirectory: URL { root.appendingPathComponent("refs/tags", isDirectory: true) }
  var heads: [URL] { refFiles(in: headsDirectory) }
  var tags: [URL] { refFiles(in: tagsDirectory) }
  var packedHeads: [Ref] { packedRefs.compactMap { $0.ref(in: "refs/heads/") } }
  var packedTags: [Ref] { packedRefs.compactMap { $0.ref(in: "refs/tags/") } }

  private var packedRefs: [PackedRef] {
    let file = root.appendingPathComponent("packed-refs")
    guard let contents = try? String(contentsOf: file) else { return [] }

    return contents
      .split(separator: "\n", omittingEmptySubsequences: false)
      .compactMap(PackedRef.init(line:))
  }

  private var packedHeadRef: Ref? {
    guard let path = try? String(contentsOf: head)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .symbolicRefPath
    else {
      return nil
    }

    return packedRefs.first { $0.name == path }?.ref
  }

}

private struct PackedRef {
  let hash: String
  let name: String

  init?(line: String.SubSequence) {
    let fields = line.split(whereSeparator: \.isWhitespace)
    guard fields.count == 2,
      let hash = fields.first,
      let name = fields.last,
      !hash.hasPrefix("#"),
      !hash.hasPrefix("^")
    else {
      return nil
    }

    self.hash = String(hash)
    self.name = String(name)
  }

  var ref: Ref {
    Ref(name: name.refName, hash: hash)
  }

  func ref(in namespace: String) -> Ref? {
    guard name.hasPrefix(namespace) else { return nil }
    return ref
  }
}

extension URL {
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
