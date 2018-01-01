public typealias ActionCompletion = () -> ()
public typealias Actions = [Action]

private final class ActionSequence {
  var sequence: Actions
  var currentAction: Action? = nil
  var index = 0
  var forever = false

  init(sequence: Actions) {
    self.sequence = sequence
    self.currentAction = sequence.first
  }

  func getNextAction() -> Action? {
    guard let currentAction = currentAction , !currentAction.completed else {
      if forever && index + 1 < sequence.count {
        index += 1
      }
      else {
        index = 0
      }

      if let action = self.currentAction , forever {
        action.completed = false
        action.timer = 0.0
      }

      self.currentAction = sequence[index]
      return self.currentAction
    }

    if !currentAction.completed {
      return currentAction
    }
    return nil
  }
}

/**
 The `Action` class provides various animation types to be applied to nodes.
 
 Any action applied to a `Node` will also be applied to any of it's child nodes.
 */
public final class Action {
  fileprivate enum ActionType {
    case moveTo(x: Float, y: Float)
    case moveBy(x: Float, y: Float)
    case rotateBy(degrees: Float)
    case scaleBy(scale: Float)
    case scaleByXY(x: Float, y: Float)
    case scaleTo(x: Float, y: Float)
    case sequence(sequence: ActionSequence)
    case group(actions: Actions)
  }

  private var actionType: ActionType
  private(set) public var duration: Double
  fileprivate var timer: Double = 0.0
  private let forever: Bool
  private var completion: ActionCompletion? = nil
  public var completed = false

  public var easingFunction: EaseFunction = .Linear
  var time: Float {
    let normalized = timer / duration
    return Float(easingFunction.function.pointAtTime(normalized))
  }

  fileprivate init(actionType: ActionType, duration: Double, forever: Bool = false, completion: ActionCompletion? = nil) {
    self.actionType = actionType
    self.duration = duration
    self.forever = forever
    self.completion = completion
  }

  func stopAction() {
    completed = true
    completion?()
  }

  func run(_ node: Node, delta: Double) {
    switch actionType {
    case .moveTo(let x, let y):
      moveTo(node, delta, x, y)
    case .moveBy(let x, let y):
      moveBy(node, delta, x, y)
    case .rotateBy(let degrees):
      rotateBy(node, delta, degrees)
    case .scaleBy(let scale):
      scaleBy(node, delta, scale)
    case .scaleByXY(let x, let y):
      scaleByXY(node, delta, x, y)
    case .scaleTo(let x, let y):
      scaleTo(node, delta, x, y)
    case .sequence(let sequence):
      sequenceActions(node, delta, sequence)
    case .group(let actions):
      groupActions(node, delta, actions)
    }

    timer += delta

    if timer >= duration && !forever {
      completed = true
      completion?()
    }
    else if timer >= duration && forever {
      timer = 0.0
    }
  }

  fileprivate func moveTo(_ node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    let dirX = x - node.position.x
    let dirY = y - node.position.y

    moveBy(node, delta, dirX, dirY)
    actionType = .moveBy(x: dirX, y: dirY)
  }


  var sPos: (x: Float, y: Float) = (0, 0) //tmp maybe
  fileprivate func moveBy(_ node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    if timer == 0.0 {
      sPos = (node.position.x, node.position.y)
    }

    node.position = Point(x: sPos.x + (time * x), y: sPos.y + (time * y))
  }

  var sRot: Float = 0.0
  fileprivate func rotateBy(_ node: Node, _ delta: Double, _ degrees: Float) {
    if timer == 0.0 {
      sRot = node.rotation
    }
    node.rotation = sRot + (time * degrees)
  }

  fileprivate func scaleTo(_ node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    var xScale: Float = max(x, node.xScale) - min(x, node.xScale)
    if node.xScale > x {
      xScale *= -1.0
    }

    var yScale = max(y, node.yScale) - min(y, node.yScale)
    if node.yScale > y {
      yScale *= -1.0
    }

    scaleByXY(node, delta, xScale, yScale)
    actionType = .scaleByXY(x: xScale, y: yScale)
  }

  fileprivate func scaleBy(_ node: Node, _ delta: Double, _ scale: Float) {
    scaleByXY(node, delta, scale, scale)
    actionType = .scaleByXY(x: scale, y: scale)
  }

  var sScale: (x: Float, y: Float) = (0, 0)
  fileprivate func scaleByXY(_ node: Node, _ delta: Double, _ x: Float, _ y: Float) {
    if timer == 0.0 {
      sScale = (node.xScale, node.yScale)
    }
    node.xScale = sScale.x + (time * x)
    node.yScale = sScale.y + (time * y)
  }

  fileprivate func sequenceActions(_ node: Node, _ delta: Double, _ sequence: ActionSequence) {
    if let action = sequence.getNextAction() {
      action.run(node, delta: delta)
    }
  }

  fileprivate func groupActions(_ node: Node, _ delta: Double, _ actions: Actions) {
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
  public static func moveTo(_ x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .moveTo(x: x, y: y), duration: duration, completion: completion)
  }

  /**
   Move a `Node` to a specific point. 
   
   This will update the `position` property of a `Node`.

   - parameter to:         The point to move to.
   - parameter duration:   How long it should take to move the node.
   - parameter completion: The closure to be run when the action is over.

   - returns: A new instance of `Action` that moves a node to a point.
   */
  public static func moveTo(_ to: Point, duration: Double, completion: ActionCompletion? = nil) -> Action {
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
  public static func moveBy(_ x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .moveBy(x: x, y: y), duration: duration)
  }

  /**
   Rotate a `Node` by given amount relative to it's current rotation.

   This will update the `rotation` property of a `Node`.

   - parameter degrees:    The amount to rotate in degrees.
   - parameter duration:   How long it should take to rotate by the given amount.
   - parameter completion: A closure to be run when the action is over.

   - returns: A new instance of `Action` that rotates a node by a given amount.
   */
  public static func rotateBy(_ degrees: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .rotateBy(degrees: degrees), duration: duration)
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
  public static func scaleTo(_ x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .scaleTo(x: x, y: y), duration: duration, completion: completion)
  }

  /**
   Uniformly scale a `Node` by a given amount relative to it's current scale.

   This will update the `scale` property of a `Node`.

   - parameter scale:      The amount to scale by.
   - parameter duration:   How long it should take to scale.
   - parameter completion: A closure to be run when the action is over.

   - returns: A new instance of `Action` that scales a node by a given amount.
   */
  public static func scaleBy(_ scale: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .scaleBy(scale: scale), duration: duration, completion: completion)
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
  public static func scaleBy(_ x: Float, y: Float, duration: Double, completion: ActionCompletion? = nil) -> Action {
    return Action(actionType: .scaleByXY(x: x, y: y), duration: duration, completion: completion)
  }

  /**
   Construct an `Action` that is a series of other actions that run when the previous action has finished, ie, in a sequence.

   - parameter sequence:   The actions to be performed in the given order.
   - parameter completion: A closure to be run when ALL of the actions are completed.

   - returns: A new instance of `Action` with a sequence of `Action`s.
   */
  public static func sequence(_ sequence: Actions, completion: ActionCompletion? = nil) -> Action {
    let duration = sequence.map { $0.duration }.reduce(0.0, +)
    return Action(actionType: .sequence(sequence: ActionSequence(sequence: sequence)), duration: duration, completion: completion)
  }

  /**
   A group of `Action`s are actions that will run in parallel.

   - parameter group:      The `Action`s to be run at the same time.
   - parameter completion: The closure to be run when the last action has completed.

   - returns: A new instance of `Action` with a group of `Action`s.
   */
  public static func group(_ group: Actions, completion: ActionCompletion? = nil) -> Action {
    let maxDuration = group.map {
      $0.duration
    }.max() ?? 0.0
    return Action(actionType: .group(actions: group), duration: maxDuration, completion: completion)
  }

  /**
   Repeat the same action forever.

   - parameter action: The `Action` to be repeated forever.

   - returns: A new instance of `Action` that will run forever.
   */
  public static func repeatForever(_ action: Action) -> Action {
    switch action.actionType {
    case .sequence(let seq):
      seq.forever = true
      action.actionType = .sequence(sequence: seq)
    case _: break
    }

    return Action(actionType: action.actionType, duration: action.duration, forever: true, completion: nil)
  }
}
