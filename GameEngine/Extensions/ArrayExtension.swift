import Foundation

extension Collection where Iterator.Element: Equatable {
  func find(_ element: Iterator.Element) -> Int? {
    for (i, v) in enumerated() {
      if v == element {
        return i
      }
    }
    return nil
  }

}

extension Array where Element: Node {
  mutating func remove(_ node: Element) -> Element? {
    if let index = find(node) {
      return self.remove(at: index)
    }
    return nil
  }
}
