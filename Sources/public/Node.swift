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
open class Node: NodeGeometry, Updateable, Tree, Equatable, Hashable {
  open var name: String? = nil

  open var scene: Scene? = nil

  var index: Int = 0
  var isUINode = false {
    didSet {
      updateTransform()
    }
  }
  
  open var size: Size {
    didSet {
      updateSize()
      updateTransform()
    }
  }

  open var frame: Rect {
    var ret = boundingRect
    allParents.forEach { parent in
      ret.x += parent.position.x - (parent.width * parent.anchorPoint.x)
      ret.y += parent.position.y - (parent.height * parent.anchorPoint.y)
    }
    ret.x -= width * anchorPoint.x
    ret.y -= height * anchorPoint.y
    return ret
  }

  open var anchorPoint = Point(x: 0.0, y: 0.0) {
    didSet { updateTransform() }
  }

  open var position = Point(x: 0, y: 0) {
    didSet { updateTransform() }
  }

  open var zPosition: Int = 0 {
    didSet { updateTransform() }
  }

  open var rotation: Float = 0.0 {
    didSet { updateTransform() }
  }

  open var xScale: Float = 1.0 {
    didSet { updateTransform() }
  }
  open var yScale: Float = 1.0 {
    didSet { updateTransform() }
  }

  open fileprivate(set) var transform: Mat4 = .identity

  weak var camera: CameraNode?

  //tree related
  fileprivate let uuid = UUID().uuidString
  open var hashValue: Int { return uuid.hashValue }
  open fileprivate(set) var nodes = Nodes()
  open fileprivate(set) var parent: Node? = nil

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
  open func update(_ delta: CFTimeInterval) {
    guard let action = self.action else { return }

    if !action.completed {
      action.run(self, delta: delta)
    }
    else {
      self.action = nil
    }
  }

  //MARK: Actions

  fileprivate(set) open var action: Action? = nil

  /// True if this `Node` or any of it's parents' `Node` is currently running an action.
  open var hasAction: Bool {
    guard action == nil else { return true }
    let parentActions = allParents.filter { $0.hasAction }
    return parentActions.count > 0
  }

  /**
   Run an `Action` on the `Node` object. 
   
   - parameter action: The action to perform on the node.
   */
  open func runAction(_ action: Action) {
    self.action = action
  }

  open func stopAction() {
    action?.stopAction()
    action = nil
  }

  //MARK: Tree stuff

  open func addNode(_ node: Node) {
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
  }

  open func removeNode<T: Node>(_ node: T?) -> T? {
    guard let node = node else { return nil }
    guard let index = nodes.find(node) else { return nil }

    if let scene = node.scene {
      return scene.removeNode(node)
    }

    return nodes.remove(at: index) as? T
  }

  //MARK: transform caching
  
  var hasTransformUpdate = false
  fileprivate var cachedModel: Mat4 = .identity
  open var model: Mat4 {
    if !hasTransformUpdate {
      return cachedModel
    }

    hasTransformUpdate = false

    cachedModel = parentTransform * transform
    return cachedModel
  }

  func updateTransform() {
    hasTransformUpdate = true
    nodes.forEach { $0.hasTransformUpdate = true }

    let x = position.x - (width * anchorPoint.x)
    let y = position.y - (height * anchorPoint.y)

    let xRot = 0.0 - (width * anchorPoint.x)
    let yRot = 0.0 - (height * anchorPoint.y)

    let scale = Mat4.scale(xScale, yScale)
    let worldTranslate = Mat4.translate(x - xRot, y - yRot, z)
    let rotation = Mat4.rotate(-1 * self.rotation)
    let rotationTranslate = Mat4.translate(xRot, yRot, z)

    var view = Mat4.identity
    if let inverseView = camera?.inverseView , isUINode {
      view = inverseView
    }

    transform = view * worldTranslate * rotation * rotationTranslate * scale
  }
}

extension Node: CustomDebugStringConvertible {
  public var debugDescription: String {
    let name = self.name ?? "\(type(of: self))"
    return name
  }
}
