//
//  Updateable.swift
//  GameEngine
//
//  Created by Anthony Green on 2/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

protocol Updateable: class, Tree {
  var time: CFTimeInterval { get }
  var action: Action? { get set }
  var hasAction: Bool { get }

  func updateWithDelta(delta: CFTimeInterval)
  func runAction(action: Action)
}
