//
//  ArrayExtension.swift
//  GameEngine
//
//  Created by Anthony Green on 5/14/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

extension CollectionType where Generator.Element: Hashable {
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
//extension CollectionType where Generator.Element: Renderable {
//  func findRenderable(renderable: Renderable) -> Int? {
//    for (i, v) in enumerate() {
//      if v == renderable {
//        return i
//      }
//    }
//    return nil
//  }
//}
