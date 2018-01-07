import Foundation
import simd

/**
 A `Scene` is a node object that holds everything on screen as the root of the node tree. Anything that needs to be displayed must be added to 
 either the scene directly or a node that is already part of the scene's tree.
 
 The scene is also responsible for setting up and maintaining the render loop.
 
 In general, this is where all the stuff should happen. Any game using this engine should subclass this and override the `update(_:)` method.

 - discussion: Unlike other `Node` types it's safe to force unwrap the `Camera` object on a scene. It will always have a default value and unless no other cameras are created
               it will be the same camera used for each node added to the scene. Also, it probably makes little sense to add a scene as a child to another scene and may cause problems.
 */
open class Scene {
  public weak var view: GameView?

  public fileprivate(set) var camera: CameraNode

  public var allNodes: Nodes {
    return graphCache.allNodes
  }

  var graphCache: GraphCache!

  /// the ambient color for when light nodes are present, defaults to white
  open var ambientLightColor: Color = Color(1.0, 1.0, 1.0, 1.0) 

  /**
   Create a scene of a given size. This will serve as the root node to which all other nodes should be added to.

   - parameter size: The size to make the scene.

   - returns: A new instance of `Scene`.
   */
  public init(size: Size) {
    camera = CameraNode(size: size)

    camera.scene = self
  }

  /**
   The scene is about to start rendering.
   
   - parameter view: The `GameView` that owns the `Scene`.
   */
  open func didMoveTo(view: GameView) {}

  /**
   This method can be overridden to perform per frame updates.

   - parameter delta: The amount of time that has passed since the last update.
   */
  open func update(delta: Double) {}
}

// MARK: Scene graph
extension Scene {
  public func add(node: Node) {
    camera.add(node: node)

    graphCache.add(node: node)
  }

  public func remove<T : Node>(node: T?) -> T? {
    if let node = camera.remove(node: node) {
      graphCache.update(node: node)
      return node
    }
    return nil
  }

  public func addUI(node: Node) {
    node.isUINode = true
    add(node: node)
  }

  func updateNode(quad: Quad, index: Int, key: Int) {
    graphCache.updateNode(quad: quad, index: index, key: key)
  }
}

// MARK: Control related
extension Scene {
  /**
   Get all nodes at a given point in world coordinates. 
   
   - note: Needs to be updated to take rotation into consideration.

   - parameter point: The point in world coordinates.

   - returns: An array of Nodes at a given point or an empty array if no nodes at point.
   */
  public func nodesAt(point: Point) -> Nodes {
    return allNodes.filter { node -> Bool in
      let rect = node.boundingRect

      let ll = rect.origin
      let ur = rect.upperRight

      //probably requires more logic here for rotation
      //also need to calculate the other corners more than likely
      return point.x > ll.x && point.x < ur.x && point.y > ll.y && point.y < ur.y
    }
  }

  /**
   Converts a point from screen coordinates to a point in the scene, ie, world coordinates.

   - parameter point: A point in screen coordinates.

   - returns: A point in the `Scene`.
   */
  public func convertPointFromView(_ point: Point) -> Point {
    guard let height = view?.bounds.size.height else {
      DLog("Scene has not yet been presented but you're trying to convert a point scene coordinates.")
      return .zero
    }

    let x = point.x
    let y = Float(height) - point.y
    let vec = Vec4(x, y, 1.0, 1.0)

    let scale = 1.0 / camera.scale
    let translate = scale * (vec - camera.view.translation)

    return Point(x: translate.x, y: translate.y)
  }

  /**
   Converts a point from scene coordinates to a point in screen coordinates.

   - parameter point: The point to convert to screen coordinates.

   - returns: A point on the device's screen.
   */
  public func convertPointFromScene(_ point: Point) -> Point {
    guard let view = view else {
      DLog("Scene has not been presented but you're trying to convert a point to screen coordinates.")
      return .zero
    }

    let x = point.x
    let y = Float(view.bounds.height) - point.y
    let vec = Vec4(x, y, 1.0, 1.0)

    let scale = 1.0 / camera.scale
    let translate = scale * (float4(camera.view.translation.x + vec.x, vec.y - camera.view.translation.y, 1.0, 1.0))

    return Point(x: translate.x, y: translate.y)
  }
}

extension Scene {
  func updateCameras(_ size: Size) {
    camera.updateSize(size)
  }
}
