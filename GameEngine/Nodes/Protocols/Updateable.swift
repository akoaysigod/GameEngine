//
//  Updateable.swift
//  GameEngine
//
//  Created by Anthony Green on 2/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

/**
 Any type that needs to be updated during the main game loop should implement the `Updateable` protocol.
 */
public protocol Updateable: Tree {
  var action: Action? { get }
  var hasAction: Bool { get }

  func update(delta: CFTimeInterval)
  func run(action: Action)
  func stopAction()
}
