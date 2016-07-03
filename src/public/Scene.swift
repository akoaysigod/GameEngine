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
public class Scene {
  public weak var view: GameView? {
    didSet {
      graphCache.bufferManager = view?.bufferManager
    }
  }

  public private(set) var camera: CameraNode
  let tileSize: Int

  public var allNodes: Nodes {
    return graphCache.allNodes
  }

  let graphCache = GraphCache()

  /// the ambient color for when light nodes are present, defaults to white
  public var ambientLightColor: Color = Color(1.0, 1.0, 1.0, 1.0)

  /**
   Create a scene of a given size. This will serve as the root node to which all other nodes should be added to.

   - parameter size: The size to make the scene.

   - returns: A new instance of `Scene`.
   */
  public init(size: Size, tileSize: Int) {
    self.tileSize = tileSize

    camera = CameraNode(size: size)

    camera.scene = self
  }

  /**
   The scene is about to start rendering.
   
   - parameter view: The `GameView` that owns the `Scene`.
   */
  public func didMoveToView(view: GameView) {}

  public func addNode(node: Node) {
    camera.addNode(node)

    graphCache.addNode(node)
  }

  public func removeNode<T : Node>(node: T?) {
    if let node = camera.removeNode(node) {
      graphCache.updateNodes(node)
    }
  }

  public func addUINode(node: Node) {
    node.isUINode = true
    addNode(node)
  }

  func updateNode(quad: Quad, index: Int, key: Int) {
    graphCache.updateNode(quad, index: index, key: key)
  }

  public func update(delta: CFTimeInterval) {}
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

    let scale = 1.0 / camera.scale
    let translate = scale * (vec - camera.view.translation)

    return Point(x: translate.x, y: translate.y)
  }
}

extension Scene {
  func updateCameras(size: Size) {
    camera.updateSize(size)
  }
}
