//
//  ArrayExtension.swift
//  GameEngine
//
//  Created by Anthony Green on 5/14/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

extension CollectionType where Generator.Element: Equatable {
  func find(element: Generator.Element) -> Int? {
    for (i, v) in enumerate() {
      if v == element {
        return i
      }
    }
    return nil
  }

}

extension Array where Element: Node {
  mutating func remove(node: Element) -> Element? {
    if let index = find(node) {
      return removeAtIndex(index)
    }
    return nil
  }
}