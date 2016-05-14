//
//  Scene.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import simd
import UIKit

/**
 A `Scene` is a node object that holds everything on screen as the root of the node tree. Anything that needs to be displayed must be added to 
 either the scene directly or a node that is already part of the scene's tree.
 
 The scene is also responsible for setting up and maintaining the render loop.
 
 In general, this is where all the stuff should happen. Any game using this engine should subclass this and override the `update(_:)` method.

 - discussion: Unlike other `Node` types it's safe to force unwrap the `Camera` object on a scene. It will always have a default value and unless no other cameras are created
               it will be the same camera used for each node added to the scene. Also, it probably makes little sense to add a scene as a child to another scene and may cause problems.
 */
public class Scene: Node {
  public weak var view: GameView?

  private var updateNodes = Nodes()
  public var allNodes: Nodes {
    return updateNodes
  }
  private var renderNodes = Renderables()
  public var allRenderables: Renderables {
    return renderNodes
  }

  var uniqueID = "1"

  public override var parent: Node? {
    return nil
  }

  public override var transform: Mat4 {
    return Mat4.identity
  }

  public override var hasAction: Bool {
    return false
  }

  /**
   Create a scene of a given size. This will serve as the root node to which all other nodes should be added to.

   - parameter size: The size to make the scene.

   - returns: A new instance of `Scene`.
   */
  public override init(size: Size) {
    super.init(size: size)

    let camera = CameraNode(size: size)
    addNode(camera)
    self.camera = camera
    self.scene = self
  }

  /**
   The scene is about to start rendering.
   
   - parameter view: The `GameView` that owns the `Scene`.
   */
  public func didMoveToView(view: GameView) {}

  public override func addNode(node: Node) {
    super.addNode(node)

    updateNodes += [node] + node.allNodes
    if let renderable = node as? Renderable {
      renderNodes += [renderable]
    }
    renderNodes += node.allRenderables
  }

  public override func removeNode<T : Node>(node: T?) -> T? {
    guard let node = node else { return nil }
    guard let index = updateNodes.find(node) else { return nil }

    let removed = updateNodes.removeAtIndex(index) as? T

    if let removedNode = removed as? Node {
      removedNode.allNodes.forEach {
        if let i = updateNodes.find($0) {
          updateNodes.removeAtIndex(i)
        }
      }
    }

    if let removedNode = removed as? Renderable {
      var indices = [Int]()
      removedNode.allRenderables.forEach {
        //bleh
        var renderIndex: Int?
        for (i, v) in renderNodes.enumerate() {
          if v == $0 {
            renderIndex = i
            break
          }
        }
        if let renderIndex = renderIndex {
          indices += [renderIndex]
        }
      }

      indices.forEach {
        renderNodes.removeAtIndex($0)
      }
    }

    super.removeNode(node)

    return removed
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
  public func nodesAtPoint(point: Point) -> Nodes {
    return allNodes.filter { node -> Bool in
      let rect = node.frame

//      let transform = node.parentTransform * node.transform
//
//      let ll = transform * Vec4(rect.origin.x, rect.origin.y, 1.0, 1.0)
//      let ur = transform * Vec4(rect.upperRight.x, rect.upperRight.y, 1.0, 1.0)
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
  public func convertPointFromView(point: Point) -> Point {
    guard let height = view?.bounds.size.height else {
      DLog("scene has not yet been present but you're trying to convert a point from view.")
      return .zero
    }

    let x = point.x
    let y = Float(height) - point.y
    let vec = Vec4(x, y, 1.0, 1.0)

    let scale = 1.0 / camera!.scale
    let translate = scale * (vec - camera!.view.translation)

    return Point(x: translate.x, y: translate.y)
  }
}
