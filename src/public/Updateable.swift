//
//  Updateable.swift
//  GameEngine
//
//  Created by Anthony Green on 2/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

protocol Updateable: class, TreeUpdateable {
  var time: CFTimeInterval { get set }
  var action: GEAction? { get set }
  var hasAction: Bool { get }

  func updateWithDelta(delta: CFTimeInterval)
  func runAction(action: GEAction)
}

extension Updateable {
  func updateWithDeltaTime(delta: CFTimeInterval) {
    time += delta

    guard let action = self.action else { return }
    if !action.completed {
      //action.run(self, delta: delta)
    }
  }

  public var hasAction: Bool {
    var performingAction = false
    while let parent = nodeTree.parent?.root {
//      if parent.hasAction {
//        performingAction = true
//        break
//      }
    }
    return action != nil || performingAction
  }

  public func runAction(action: GEAction) {
    self.action = action
  }
}