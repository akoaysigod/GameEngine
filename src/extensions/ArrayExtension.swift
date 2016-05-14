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

//bleh I'll figure out how to make Renderables equatable at some point
//other protocol problems, etc
extension CollectionType {
  func findRenderable(node: Node) -> Int? {
    guard let renderable = node as? Renderable else { return nil }

    let renderables = self.filter { $0 is Renderable }.flatMap { $0 as? Renderable }
    guard renderables.count > 0 else { return nil }

    for (i, v) in renderables.enumerate() {
      if v == renderable {
        return i
      }
    }
    return nil
  }
}
