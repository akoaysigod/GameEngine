//
//  GEAnimation.swift
//  MKTest
//
//  Created by Anthony Green on 1/2/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import GLKit

public typealias ActionCompletion = () -> ()
public typealias GEActions = [GEAction]

final class ActionSequence {
  var sequence: GEActions
  var currentAction: GEAction? = nil

  init(sequence: GEActions) {
    self.sequence = sequence
  }

  func getNextAction() -> GEAction? {
    guard let currentAction = self.currentAction where !currentAction.completed else {
      self.currentAction = self.sequence.count > 0 ? self.sequence.removeFirst() : nil
      return self.currentAction
    }
    return currentAction
  }
}

public final class GEAction {
  enum ActionType {
    case MoveTo(x: Float, y: Float)
    case MoveBy(x: Float, y: Float)
    case RotateBy(degrees: Float)
    case ScaleBy(scale: Float)
    case ScaleByXY(x: Float, y: Float)
    case ScaleTo(x: Float, y: Float)
    case Sequence(sequence: ActionSequence)
    case Group(actions: GEActions)
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

  func run(node: GENode, delta: Double) {
    switch self.actionType {
    case .MoveTo(let x, let y):
      self.moveTo(node, delta, x, y)
    case .MoveBy(let x, let y):
      self.moveBy(node, delta, x, y)
    case .RotateBy(let degrees):
      self.rotateBy(node, delta, degrees)
    case .ScaleBy(let scale):
      self.scaleBy(node, delta, scale)
    case .ScaleByXY(let x, let y):
      self.scaleByXY(node, delta, x, y)
    case .ScaleTo(let x, let y):
      self.scaleTo(node, delta, x, y)
    case .Sequence(let sequence):
      self.sequenceActions(node, delta, sequence)
    case .Group(let actions):
      self.groupActions(node, delta, actions)
    }

    self.timer -= delta

    if self.timer <= 0.0 {
      self.completed = true
    }
  }

  private func moveTo(node: GENode, _ delta: Double, _ x: Float, _ y: Float) {
    let dirX = x - node.x
    let dirY = y - node.y

    self.moveBy(node, delta, dirX, dirY)
    self.actionType = .MoveBy(x: dirX, y: dirY)
  }

  private func moveBy(node: GENode, _ delta: Double, _ x: Float, _ y: Float) {
    node.x += Float(delta) * x
    node.y += Float(delta) * y
  }

  private func rotateBy(node: GENode, _ delta: Double, _ degrees: Float) {
    node.rotation += Float(delta) * degrees
  }

  private func scaleBy(node: GENode, _ delta: Double, _ scale: Float) {
    node.xScale += Float(delta) * scale
    node.yScale += Float(delta) * scale
  }

  private func scaleByXY(node: GENode, _ delta: Double, _ x: Float, _ y: Float) {
    node.xScale += Float(delta) * x
    node.yScale += Float(delta) * y
  }

  private func scaleTo(node: GENode, _ delta: Double, _ x: Float, _ y: Float) {
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

  private func sequenceActions(node: GENode, _ delta: Double, _ sequence: ActionSequence) {
    if let action = sequence.getNextAction() {
      action.run(node, delta: delta)
    }
  }

  private func groupActions(node: GENode, _ delta: Double, _ actions: GEActions) {
    actions.forEach { action in
      action.run(node, delta: delta)
    }
  }
}

extension GEAction {
  public static func moveTo(to: CGPoint, duration: Double, completion: ActionCompletion? = nil) -> GEAction {
    return GEAction(actionType: .MoveTo(x: to.float.x, y: to.float.y), duration: duration, completion: completion)
  }

  public static func moveTo(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> GEAction {
    return GEAction(actionType: .MoveTo(x: x, y: y), duration: duration, completion: completion)
  }

  public static func moveBy(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> GEAction {
    return GEAction(actionType: .MoveBy(x: x, y: y), duration: duration)
  }

  public static func rotateBy(degrees: Float, duration: Double, completion: ActionCompletion? = nil) -> GEAction {
    return GEAction(actionType: .RotateBy(degrees: degrees), duration: duration)
  }

  public static func scaleBy(scale: Float, duration: Double, completion: ActionCompletion? = nil) -> GEAction {
    return GEAction(actionType: .ScaleBy(scale: scale), duration: duration, completion: completion)
  }

  public static func scaleBy(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> GEAction {
    return GEAction(actionType: .ScaleByXY(x: x, y: y), duration: duration, completion: completion)
  }

  public static func scaleTo(x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> GEAction {
    return GEAction(actionType: .ScaleTo(x: x, y: y), duration: duration, completion: completion)
  }

  public static func sequence(sequence: GEActions, completion: ActionCompletion? = nil) -> GEAction {
    let duration = sequence.map { $0.duration }.reduce(0.0, combine: +)
    return GEAction(actionType: .Sequence(sequence: ActionSequence(sequence: sequence)), duration: duration, completion: completion)
  }

  public static func group(group: GEActions, completion: ActionCompletion? = nil) -> GEAction {
    let maxDuration = group.map {
      $0.duration
    }.maxElement() ?? 0.0
    return GEAction(actionType: .Group(actions: group), duration: maxDuration, completion: completion)
  }
  
  public static func repeatForever(action: GEAction) -> GEAction {
    return GEAction(actionType: action.actionType, duration: Double.infinity, completion: nil)
  }
}
