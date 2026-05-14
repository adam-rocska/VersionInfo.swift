import Foundation

struct Refs {
  let head: Ref

  let heads: [Ref]
  let tags: [Ref]

  init?(gitDir: URL) {
    let git = GitDirectory(root: gitDir)
    guard let head = git.headRef else { return nil }

    self.head = head
    heads = Self.merging(
      git.heads.compactMap { Ref(file: $0, relativeTo: git.headsDirectory) },
      over: git.packedHeads
    )
    tags = Self.merging(
      git.tags.compactMap { Ref(file: $0, relativeTo: git.tagsDirectory) },
      over: git.packedTags
    )
  }

  private static func merging(_ loose: [Ref], over packed: [Ref]) -> [Ref] {
    Dictionary(
      (packed + loose).map { ($0.name, $0) },
      uniquingKeysWith: { _, loose in loose }
    )
    .values
    .sorted { $0.name < $1.name }
  }
}
