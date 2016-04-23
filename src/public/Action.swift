//
//  Animation.swift
//  MKTest
//
//  Created by Anthony Green on 1/2/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import UIKit

public typealias ActionCompletion = () -> ()
public typealias Actions = [Action]

private final class ActionSequence {
  var sequence: Actions
  var currentAction: Action? = nil

  init(sequence: Actions) {
    self.sequence = sequence
  }

  func getNextAction() -> Action? {
    guard let currentAction = self.currentAction where !currentAction.completed else {
      self.currentAction = self.sequence.count > 0 ? self.sequence.removeFirst() : nil
      return self.currentAction
    }
    return currentAction
  }
}

/**
 The `Action` class provides various animation types to be applied to nodes.
 
 Any action applied to a `Node` will also be applied to any of it's child nodes.
 */
public final class Action {
  private enum ActionType {
    case MoveTo(x: Float, y: Float)
    case MoveBy(x: Float, y: Float)
    case RotateBy(degrees: Float)
    case ScaleBy(scale: Float)
    case ScaleByXY(x: Float, y: Float)
    case ScaleTo(x: Float, y: Float)
    case Sequence(sequence: ActionSequence)
    case Group(actions: Actions)
  }

  private var actionType: ActionType
  public var duration: Double
  private var timer: Double
  public var completion: ActionCompletion? = nil
  public var completed = false

  private init(actionType: ActionType, duration: Double, completion: ActionCompletion? = nil) {
    self.actionType = actionType
    self.duration = duration
    self.timer = duration
    self.completion = completion
  }

  func stopAction() {
    completed = true
    completion?()
  }

  func run(node: Node, delta: Double) {
    switch actionType {
    case .MoveTo(let x, let y):
      moveTo(node, delta, x, y)
    case .MoveBy(let x, let y):
      moveBy(node, delta, x, y)
    case .RotateBy(let degrees):
      rotateBy(node, delta, degrees)
    case .ScaleBy(let scale):
      scaleBy(node, delta, scale)
    case .ScaleByXY(let x, let y):
      scaleByXY(node, delta, x, y)
    case .ScaleTo(let x, let y):
      scaleTo(node, delta, x, y)
    case .Sequence(let sequence):
      sequenceActions(node, delta, sequence)
    case .Group(let actions):
      groupActions(node, delta, actions)
    }

    timer -= delta

    if timer <= 0.0 {
      completed = true
      completion?()
    }
  }

  private func moveTo(node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    let dirX = x - node.x
    let dirY = y - node.y

    self.moveBy(node, delta, dirX, dirY)
    self.actionType = .MoveBy(x: dirX, y: dirY)
  }

  private func moveBy(node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    node.x += Float(delta) * x
    node.y += Float(delta) * y
  }

  private func rotateBy(node: Node, _ delta: Double, _ degrees: Float) {
    node.rotation += Float(delta) * degrees
  }

  private func scaleBy(node: Node, _ delta: Double, _ scale: Float) {
    node.xScale += Float(delta) * scale
    node.yScale += Float(delta) * scale
  }

  private func scaleByXY(node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    node.xScale += Float(delta) * x
    node.yScale += Float(delta) * y
  }

  private func scaleTo(node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    var xScale: Float = max(x, node.xScale) - min(x, node.xScale)
    if node.xScale > x {
      xScale *= -1.0
    }

    var yScale = max(y, node.yScale) - min(y, node.yScale)
    if node.yScale > y {
      yScale *= -1.0
    }

    self.scaleByXY(node, delta, xScale, yScale)
    self.actionType = .ScaleByXY(x: xScale, y: yScale)
  }

  private func sequenceActions(node: Node, _ delta: Double, _ sequence: ActionSequence) {
    if let action = sequence.getNextAction() {
      action.run(node, delta: delta)
    }
  }

  private func groupActions(node: Node, _ delta: Double, _ actions: Actions) {
    actions.forEach { action in
      action.run(node, delta: delta)
    }
  }
}

extension Action {
  /**
   Move a `Node` to a specific point. 
   
   This will update the `position` property of a `Node`.

   - parameter x:          The x coordinate to move to.
   - parameter y:          The y coordinate to move to.
   - parameter duration:   How long it should take to move the node.
   - parameter completion: The closure to be run when the action is over.

   - returns: A new instance of `Action` that moves a node to a point.
   */
  public static func moveTo(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .MoveTo(x: x, y: y), duration: duration, completion: completion)
  }

  /**
   Move a `Node` to a specific point. 
   
   This will update the `position` property of a `Node`.

   - parameter to:         The point to move to.
   - parameter duration:   How long it should take to move the node.
   - parameter completion: The closure to be run when the action is over.

   - returns: A new instance of `Action` that moves a node to a point.
   */
  public static func moveTo(to: CGPoint, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action.moveTo(Float(to.x), y: Float(to.y), duration: duration, completion: completion)
  }

  /**
   Move a `Node` by a relative amount from it's current position. 
   
   This will update the `position` property of a `Node`.

   - parameter x:          The amount in the x direction to move by.
   - parameter y:          The amount in the y direction to move by.
   - parameter duration:   How long it should take to move the node.
   - parameter completion: The closure to be run when the action is over.

   - returns: A new instance of `Action` that moves a node by a given amount.
   */
  public static func moveBy(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .MoveBy(x: x, y: y), duration: duration)
  }

  /**
   Rotate a `Node` by given amount relative to it's current rotation.

   This will update the `rotation` property of a `Node`.

   - parameter degrees:    The amount to rotate in degrees.
   - parameter duration:   How long it should take to rotate by the given amount.
   - parameter completion: A closure to be run when the action is over.

   - returns: A new instance of `Action` that rotates a node by a given amount.
   */
  public static func rotateBy(degrees: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .RotateBy(degrees: degrees), duration: duration)
  }

  /**
   Uniformly scale a `Node` by a given amount relative to it's current scale.

   This will update the `scale` property of a `Node`.

   - parameter scale:      The amount to scale by.
   - parameter duration:   How long it should take to scale.
   - parameter completion: A closure to be run when the action is over.

   - returns: A new instance of `Action` that scales a node by a given amount.
   */
  public static func scaleBy(scale: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .ScaleBy(scale: scale), duration: duration, completion: completion)
  }

  /**
   Scale a `Node` in the x and y direction by a given amount relative to it's current scale.
   
   This will update the `scale` property of a `Node`.

   - parameter x:          The amount to scale in the x direction.
   - parameter y:          The amount to scale in the y direction.
   - parameter duration:   How long it should take to scale.
   - parameter completion: A closure to be run when the action is over.

   - returns: A new instance of `Action` that scales a node by a given amount.
   */
  public static func scaleBy(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .ScaleByXY(x: x, y: y), duration: duration, completion: completion)
  }

  /**
   Scale a `Node` to a certain size along the x and y axes.
   
   This will update the `scale` property of a `Node`.

   - parameter x:          The amount to scale in the x direction.
   - parameter y:          The amount to scale in the y direction.
   - parameter duration:   How long it should take to scale.
   - parameter completion: A closure to be run when the action is over.

   - returns: A new instance of `Action` that scales a node to a given amount.
   */
  public static func scaleTo(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .ScaleTo(x: x, y: y), duration: duration, completion: completion)
  }

  /**
   Construct an `Action` that is a series of other actions that run when the previous action has finished, ie, in a sequence.

   - parameter sequence:   The actions to be performed in the given order.
   - parameter completion: A closure to be run when ALL of the actions are completed.

   - returns: A new instance of `Action` with a sequence of `Action`s.
   */
  public static func sequence(sequence: Actions, completion: ActionCompletion? = nil) -> Action {
    let duration = sequence.map { $0.duration }.reduce(0.0, combine: +)
    return Action(actionType: .Sequence(sequence: ActionSequence(sequence: sequence)), duration: duration, completion: completion)
  }

  /**
   A group of `Action`s are actions that will run in parallel.

   - parameter group:      The `Action`s to be run at the same time.
   - parameter completion: The closure to be run when the last action has completed.

   - returns: A new instance of `Action` with a group of `Action`s.
   */
  public static func group(group: Actions, completion: ActionCompletion? = nil) -> Action {
    let maxDuration = group.map {
      $0.duration
    }.maxElement() ?? 0.0
    return Action(actionType: .Group(actions: group), duration: maxDuration, completion: completion)
  }

  /**
   Repeat the same action forever.

   - parameter action: The action to be forever repeated.

   - returns: A new instance of `Action` that will run forever.
   */
  public static func repeatForever(action: Action) -> Action {
    return Action(actionType: action.actionType, duration: Double.infinity, completion: nil)
  }
}
