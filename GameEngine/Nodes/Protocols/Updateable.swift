import Foundation

/**
 Any type that needs to be updated during the main game loop should implement the `Updateable` protocol.
 */
public protocol Updateable: Tree {
  /// The action to be run.
  var action: Action? { get }

  /// True if this `Node` or any of it's parents' `Node` is currently running an action.
  var hasAction: Bool { get }

  /**
   A function that's called on every frame update. When subclassing `Node` be sure to call super in this function.

   - parameter delta: The amount of time that's passed since this function was last called.
   */
  func update(delta: CFTimeInterval)

  /**
   Run an `Action` on the `Node` object.

   - parameter action: The action to perform on the node.
   */
  func run(action: Action)

  /// Stop the current action from running.
  func stopAction()
}
