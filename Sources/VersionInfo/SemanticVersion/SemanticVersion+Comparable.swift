extension SemanticVersion: Comparable {
  public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    guard lhs.major == rhs.major else { return lhs.major < rhs.major }
    guard lhs.minor == rhs.minor else { return lhs.minor < rhs.minor }
    guard lhs.patch == rhs.patch else { return lhs.patch < rhs.patch }

    switch (lhs.prerelease, rhs.prerelease) {
    case (nil, nil), (nil, _?): return false
    case (_?, nil): return true
    case (let lhs?, let rhs?):
      return lhs.precedes(rhs)
    }
  }
}

extension String {
  fileprivate func precedes(_ other: String) -> Bool {
    let lhsIdentifiers = split(separator: ".", omittingEmptySubsequences: false)
    let rhsIdentifiers = other.split(
      separator: ".",
      omittingEmptySubsequences: false
    )

    for (lhs, rhs) in zip(lhsIdentifiers, rhsIdentifiers) {
      guard lhs != rhs else { continue }
      return lhs.precedes(rhs)
    }

    return lhsIdentifiers.count < rhsIdentifiers.count
  }
}

extension Substring {
  fileprivate func precedes(_ other: Substring) -> Bool {
    switch (isASCIINumeric, other.isASCIINumeric) {
    case (true, true): return precedesNumerically(other)
    case (true, false): return true
    case (false, true): return false
    case (false, false):
      return
        utf8
        .lexicographicallyPrecedes(other.utf8)
    }
  }

  fileprivate func precedesNumerically(_ other: Substring) -> Bool {
    guard utf8.count == other.utf8.count else {
      return utf8.count < other.utf8.count
    }

    return utf8.lexicographicallyPrecedes(other.utf8)
  }

  fileprivate var isASCIINumeric: Bool {
    !isEmpty && utf8.allSatisfy { 48...57 ~= $0 }
  }
}
