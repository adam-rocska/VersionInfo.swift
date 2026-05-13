import Foundation

public struct GitFixture: Sendable {
  public let gitDirectory: URL
  public let headName: String
  public let headHash: String
  public let branches: [String: String]
  public let tags: [String: String]

  public static let mainHash = "1111111111111111111111111111111111111111"
  public static let releaseHash = "2222222222222222222222222222222222222222"
  public static let featureHash = "3333333333333333333333333333333333333333"
  public static let tagHash = "4444444444444444444444444444444444444444"

  @discardableResult
  public static func create(
    in packageDirectory: URL,
    headName: String = "main",
    headHash: String = mainHash,
    branches: [String: String] = ["main": mainHash],
    tags: [String: String] = ["1.2.3": tagHash]
  ) throws -> GitFixture {
    let gitDirectory = packageDirectory.appendingPathComponent(".git", isDirectory: true)
    try FileManager.default.createDirectory(at: gitDirectory, withIntermediateDirectories: true)
    try "ref: refs/heads/\(headName)\n".write(
      to: gitDirectory.appendingPathComponent("HEAD"),
      atomically: true,
      encoding: .utf8
    )

    var branches = branches
    branches[headName] = headHash

    for (name, hash) in branches {
      try write(hash: hash, to: gitDirectory, namespace: "refs/heads", name: name)
    }

    for (name, hash) in tags {
      try write(hash: hash, to: gitDirectory, namespace: "refs/tags", name: name)
    }

    return GitFixture(
      gitDirectory: gitDirectory,
      headName: headName,
      headHash: headHash,
      branches: branches,
      tags: tags
    )
  }

  @discardableResult
  public static func createDetachedHead(
    in packageDirectory: URL,
    headHash: String = mainHash,
    branches: [String: String] = [:],
    tags: [String: String] = ["1.2.3": tagHash]
  ) throws -> GitFixture {
    let gitDirectory = packageDirectory.appendingPathComponent(".git", isDirectory: true)
    try FileManager.default.createDirectory(at: gitDirectory, withIntermediateDirectories: true)
    try "\(headHash)\n".write(
      to: gitDirectory.appendingPathComponent("HEAD"),
      atomically: true,
      encoding: .utf8
    )

    for (name, hash) in branches {
      try write(hash: hash, to: gitDirectory, namespace: "refs/heads", name: name)
    }

    for (name, hash) in tags {
      try write(hash: hash, to: gitDirectory, namespace: "refs/tags", name: name)
    }

    return GitFixture(
      gitDirectory: gitDirectory,
      headName: "HEAD",
      headHash: headHash,
      branches: branches,
      tags: tags
    )
  }

  private static func write(hash: String, to gitDirectory: URL, namespace: String, name: String) throws {
    let file = gitDirectory
      .appendingPathComponent(namespace, isDirectory: true)
      .appendingPathComponent(name)
    try FileManager.default.createDirectory(
      at: file.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try "\(hash)\n".write(to: file, atomically: true, encoding: .utf8)
  }
}
