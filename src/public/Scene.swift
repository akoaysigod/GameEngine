//
//  Scene.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import UIKit

// since this and GameView have been refactored a lot it might make sense to move this rendering logic into the GameViewController since that holds the main loop anyway. Who knows. I'll think about it.

/**
 A `Scene` is a node object that holds everything on screen as the root of the node tree. Anything that needs to be displayed must be added to 
 either the scene directly or a node that is already part of the scene's tree.
 
 The scene is also responsible for setting up and maintaining the render loop.
 
 In general, this is where all the stuff should happen. Any game using this engine should subclass this and override the `update(_:)` method.

 - discussion: Unlike other `Node` types it's safe to force unwrap the `Camera` object on a scene. It will always have a default value and unless no other cameras are created
               it will be the same camera used for each node added to the scene. Also, it probably makes little sense to add a scene as a child to another scene and may cause problems.
 */
public class Scene: Node {
  private var renderer: Renderer!

  var visible = false
  var uniqueID = "1"

  public override var parent: Node? {
    return nil
  }

  /**
   Create a scene of a given size. This will serve as the root node to which all other nodes should be added to.

   - parameter size: The size to make the scene.

   - returns: A new instance of `Scene`.
   */
  public override init(size: Size) {
    super.init(size: size)

    self.name = "scene"
    self.camera = CameraNode(size: size)
  }

  /**
   The scene is partially responsible for controlling the render loop. This method basically kicks off the whole app.

   - parameter view: The view that has the MTLDevice property.
   */
  func setupRenderer(view: GameView) {
    self.renderer = Renderer(view: view)
    Fonts.cache.device = view.device!
  }

  /**
   This is more or less the game loop. 
   
   - note: Although this loop is actually set up in `GameViewController` that's only because Metal forced that upon me. I may change this
           back to a CADisplayLink loop at some point but I believe this is easier for cross platform, ie, OSX, tvOS, etc. So this should be 
           the main loop for any game using this engine.
   
   - parameter timeSinceLastUpdate: The amount of time that's passed since this method was last called.
   */
  public override func update(delta: CFTimeInterval) {
    let nodes = getAllNodes()

    nodes.forEach { node in
      node.update(delta)
    }

    let drawables = nodes.flatMap { node -> Renderables in
      if let renderable = node as? Renderable {
        return [renderable]
      }
      return []
    }

    autoreleasepool {
      renderer.draw(drawables)
    }
  }
}
