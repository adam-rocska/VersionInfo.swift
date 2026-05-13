import Foundation

struct Refs {
  let head: Ref

  let heads: [Ref]
  let tags: [Ref]

  init?(gitDir: URL) {
    let git = GitDirectory(root: gitDir)
    guard let head = Ref(HEAD: git.head) else { return nil }

    self.head = head
    heads = git.heads.compactMap { Ref(file: $0, relativeTo: git.headsDirectory) }
    tags = git.tags.compactMap { Ref(file: $0, relativeTo: git.tagsDirectory) }
  }
}
