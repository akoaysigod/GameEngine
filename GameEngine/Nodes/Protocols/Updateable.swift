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
