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
import simd
import UIKit

public typealias Nodes = [Node]

public func ==(rhs: Node, lhs: Node) -> Bool {
   return rhs.hashValue == lhs.hashValue
}

func ==(lhs: Renderable, rhs: Renderable) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

func ==(lhs: Renderable, rhs: Node) -> Bool {
  return lhs.hashValue == rhs.hashValue
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
public class Node: NodeGeometry, Updateable, Tree, RenderTree, Equatable, Hashable {
  public var name: String? = nil

  public var scene: Scene? = nil
  
  public var size: Size {
    didSet {
      updateSize()
      updateTransform()
    }
  }

  public var frame: Rect {
    var ret = boundingRect
    allParents.forEach { parent in
      ret.x += parent.x - (parent.width * parent.anchorPoint.x)
      ret.y += parent.y - (parent.height * parent.anchorPoint.y)
    }
    ret.x -= width * anchorPoint.x
    ret.y -= height * anchorPoint.y
    return ret
  }

  public var anchorPoint = Point(x: 0.0, y: 0.0) {
    didSet { updateTransform() }
  }

  public var x: Float = 0.0 {
    didSet { updateTransform() }
  }
  public var y: Float = 0.0 {
    didSet { updateTransform() }
  }

  public var zPosition: Int = 0 {
    didSet { updateTransform() }
  }

  public var rotation: Float = 0.0 {
    didSet { updateTransform() }
  }

  public var xScale: Float = 1.0 {
    didSet { updateTransform() }
  }
  public var yScale: Float = 1.0 {
    didSet { updateTransform() }
  }

  public private(set) var transform: Mat4 = .identity

  public weak var camera: CameraNode?

  //tree related
  private var uuid = NSUUID().UUIDString
  public var hashValue: Int { return uuid.hashValue }
  public private(set) var nodes = Nodes()
  public private(set) var parent: Node? = nil

  //render tree
  public private(set) var renderableNodes = Renderables()

  /**
   Designated initializer. 
   
   - note: The default size of a `Node` is .zero since a node does not necessarily get rendered.
           It can still, however, be part of a `Scene` and moved around as such.

   - parameter size: The size in the scene.

   - returns: A new instance of `Node`.
   */
  public init(size: Size = .zero) {
    self.size = size
    updateTransform()
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
    guard action == nil else { return true }
    let parentActions = allParents.filter { $0.hasAction }
    return parentActions.count > 0
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

  public func addNode(node: Node) {
    guard node.parent == nil else {
      DLog("Node already has parent node.")
      return
    }
    guard node.scene == nil else {
      DLog("Node has already been added to a scene.")
      return
    }

    node.scene = scene
    node.parent = self

    node.allNodes.forEach {
      //I have no idea if this is the best way to handle adding more cameras to the scene
      //This will probably break in a weird way someday.
      $0.scene = scene
      if $0.camera == nil {
        $0.camera = camera
      }
    }

    if node.camera == nil {
      node.camera = camera
    }

    nodes += [node]

    if let renderable = node as? Renderable {
      renderableNodes += [renderable]
    }
  }

  public func removeNode<T: Node>(node: T?) -> T? {
    guard let node = node else { return nil }
    guard let index = nodes.find(node) else { return nil }

    if let scene = node.scene {
      scene.updateNodes(node)
    }

    let removed = nodes.removeAtIndex(index) as? T

    if let renderable = removed as? Node {
      if let renderIndex = renderableNodes.findRenderable(renderable) {
        renderableNodes.removeAtIndex(renderIndex)
      }
    }

    return removed
  }

  //MARK: transform caching
  func updateTransform() {
    let x = self.x - (width * anchorPoint.x)
    let y = self.y - (height * anchorPoint.y)

    let xRot = 0.0 - (width * anchorPoint.x)
    let yRot = 0.0 - (height * anchorPoint.y)

    let scale = Mat4.scale(xScale, yScale)
    let worldTranslate = Mat4.translate(x - xRot, y - yRot, z)
    let rotation = Mat4.rotate(-1 * self.rotation)
    let rotationTranslate = Mat4.translate(xRot, yRot, z)

    transform = worldTranslate * rotation * rotationTranslate * scale
  }
}

extension Node: CustomDebugStringConvertible {
  public var debugDescription: String {
    let name = self.name ?? "\(self.dynamicType)"
    return name
  }
}
