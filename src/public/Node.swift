//
//  Node.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import QuartzCore
import UIKit

public typealias Nodes = [Node]

public func ==(rhs: Node, lhs: Node) -> Bool {
   return rhs.hashValue == lhs.hashValue
}

/**
 A `Node` is the most basic object from which most game type objects should be subclassed from.
 
 This type cannot be rendered but contains all the necessary geometry to be used as if it were being displayed. 
 It also contains the relevant information for adding and removing nodes to the tree hierarchy, running actions, and updating.
 
 The following classes are subclasses of this and in general should be sufficient for most purposes.
 - Scene
 - ShapeNode
 - SpriteNode
 - TextNode
 - Camera
 */
public class Node: NodeGeometry, Tree, Equatable, Hashable {
  public var name: String? = nil
  
  public var size: CGSize {
    didSet {
      updateSize()
    }
  }

  public var anchorPoint: (x: Float, y: Float) = (x: 0.0, y: 0.0)

  public var x: Float = 0.0
  public var y: Float = 0.0

  public var zPosition: Int = 0

  public var rotation: Float = 0.0

  public var xScale: Float = 1.0
  public var yScale: Float = 1.0
  
  public var camera: Camera?

  //tree related
  private var uuid = NSUUID().UUIDString
  public var hashValue: Int { return uuid.hashValue }
  private var nodeSet = Set<Node>()
  public var nodes: Nodes {
    return Array(nodeSet)
  }
  public private(set) var parent: Node? = nil

  /**
   Designated initializer. 
   
   - note: The default size of a `Node` is .zero since a node does not necessarily get rendered.
           It can still, however, be part of a `Scene` and moved around as such.

   - parameter size: The size in the scene.

   - returns: A new instance of `Node`.
   */
  public init(size: CGSize = .zero) {
    self.size = size
  }
  
  /**
   A function that's called on every frame update. When subclassing `Node` be sure to call super in this function.

   - parameter delta: The amount of time that's passed since this function was last called.
   */
  public func update(delta: CFTimeInterval) {
    guard let action = self.action else { return }
    if !action.completed {
      action.run(self, delta: delta)
    }
    else {
      self.action = nil
    }
  }

  //MARK: Actions

  private(set) public var action: Action? = nil

  /// True if this `Node` or any of it's parents' `Node` is currently running an action.
  public var hasAction: Bool {
    var performingAction = parent?.hasAction ?? false
    while let parent = parent?.parent where !performingAction {
      guard parent.hasAction else { continue }
      performingAction = true
    }
    return action != nil || performingAction
  }

  /**
   Run an `Action` on the `Node` object. 
   
   - parameter action: The action to perform on the node.
   */
  public func runAction(action: Action) {
    self.action = action
  }

  public func stopAction() {
    action?.stopAction()
    action = nil
  }

  //MARK: Tree stuff

  /**
   Add a `Node` to this `Node`'s tree hiearchy.

   - parameter node: The node to add to the tree.
   */
  public func addNode(node: Node) {
    node.camera = camera
    node.parent = self
    nodeSet.insert(node)
  }

  /**
   Remove a `Node` from this `Node`'s tree hiearchy.

   - parameter node: The node to remove.

   - returns: The `Node` removed if it existed.
   */
  public func removeNode<T: Node>(node: T?) -> T? {
    guard let node = node else { return nil }
    let optNode = nodeSet.remove(node) as? T
    optNode?.parent = nil
    return optNode
  }
}

extension Node: CustomDebugStringConvertible {
  public var debugDescription: String {
    let name = self.name ?? "\(self.dynamicType)"
    return name
  }
}
