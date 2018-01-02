import Foundation
import Metal
import QuartzCore
import simd
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

public typealias Nodes = [Node]

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
open class Node: NodeGeometry, Tree, Hashable {
  public var name: String? = nil

  public var scene: Scene? = nil

  var index: Int = 0
  var isUINode = false {
    didSet {
      updateTransform()
    }
  }
  
  public var size: Size {
    didSet {
      updateSize()
      updateTransform()
    }
  }

  public var frame: Rect {
    var ret = boundingRect
    allParents.forEach { parent in
      ret.x += parent.position.x - (parent.width * parent.anchorPoint.x)
      ret.y += parent.position.y - (parent.height * parent.anchorPoint.y)
    }
    ret.x -= width * anchorPoint.x
    ret.y -= height * anchorPoint.y
    return ret
  }

  public var anchorPoint = Point(x: 0.0, y: 0.0) {
    didSet { updateTransform() }
  }

  public var position = Point(x: 0, y: 0) {
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

  weak var camera: CameraNode?

  //tree related
  private let uuid = UUID().uuidString
  public var hashValue: Int { return uuid.hashValue }
  public private(set) var nodes = Nodes()
  public private(set) var parent: Node? = nil

  private(set) public var action: Action? = nil

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
  
  open func update(delta: CFTimeInterval) {
    guard let action = self.action else { return }

    if !action.completed {
      action.run(self, delta: delta)
    }
    else {
      self.action = nil
    }
  }

  //MARK: Tree stuff

  open func add(node: Node) {
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

  open func remove<T: Node>(node: T?) -> T? {
    guard let node = node else { return nil }
    guard let index = nodes.find(node) else { return nil }

    if let scene = node.scene {
      return scene.remove(node: node)
    }

    return nodes.remove(at: index) as? T
  }

  //MARK: transform caching
  
  var hasTransformUpdate = false
  private var cachedModel: Mat4 = .identity
  public var model: Mat4 {
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
    let rotation = Mat4.rotate(degrees: -1 * self.rotation)
    let rotationTranslate = Mat4.translate(xRot, yRot, z)

    var view = Mat4.identity
    if let inverseView = camera?.inverseView , isUINode {
      view = inverseView
    }

    transform = view * worldTranslate * rotation * rotationTranslate * scale
  }
}

extension Node: Updateable {
  public var hasAction: Bool {
    guard action == nil else { return true }
    let parentActions = allParents.filter { $0.hasAction }
    return parentActions.count > 0
  }

  open func run(action: Action) {
    self.action = action
  }

  open func stopAction() {
    action?.stopAction()
    action = nil
  }
}

extension Node: Equatable {
  public static func ==(rhs: Node, lhs: Node) -> Bool {
    return rhs.hashValue == lhs.hashValue
  }
}

extension Node: CustomDebugStringConvertible {
  public var debugDescription: String {
    let name = self.name ?? "\(type(of: self))"
    return name
  }
}
