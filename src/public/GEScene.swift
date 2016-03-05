//
//  GEScene.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal

//TODO: refactor this, can probably make it a node type also

public class GEScene: GETree {
  public var size: CGSize
  public var camera: GECamera

  #if DEBUG
  var debugCamera: GECamera
  var fpsText: GETextLabel
  #endif
  
  private var device: MTLDevice!
  private var metalLayer: CAMetalLayer!
  private var renderer: Renderer!

  private var nodeSet = Set<GENode>()
  public var nodes: GENodes {
     return Array(nodeSet)
   }

  var visible = false
  var uniqueID = "1"

  public private(set) var parent: GENode? = nil

  init(size: CGSize) {
    self.size = size
    self.camera = GECamera(size: size)

    #if DEBUG
      self.debugCamera = GECamera(size: size)
      self.fpsText = GETextLabel(text: "00", font: UIFont.systemFontOfSize(16), color: UIColor.whiteColor())
      fpsText.name = "FPS Debug text"
      //fpsText.position = (300, 0)
      fpsText.camera = debugCamera
    #endif

    //nodeSet.insert(camera)
  }
  
  func setupRenderer(view: GEView) {
    self.device = view.device!
    self.renderer = Renderer(view: view)
    Fonts.cache.device = self.device

    addNode(fpsText)
  }
  
  public func update(timeSinceLastUpdate: CFTimeInterval) {
    let nodes = getAllNodes()

    nodes.forEach { (node) -> () in
      node.updateWithDelta(timeSinceLastUpdate)
    }

    let drawables = nodes.flatMap { node -> Renderables in
      if let renderable = node as? Renderable {
        renderable.setupBuffers(self.device)
        return [renderable]
      }
      return []
    }

    autoreleasepool { () -> () in
      renderer.draw(drawables)
    }
  }

  //need to figure out a nicer way to do this
  //the camera system is currently working but not in a very nice way but that might be ok? it needs to be manually added as a property setter 
  //adding things to a camera node works kind of weird
  //also since the relevant methods loadtexture, buildmesh, etc need to happen once they're added 
  //and since not everything gets added to the scene this doesn't make a lot of sense
  public func addNode(node: GENode) {
    if let sprite = node as? GESprite {
      sprite.loadTexture(device)
    }

    //TODO: tmp
    if let textNode = node as? GETextLabel {
      textNode.buildMesh(device)
    }
    
    if let renderNode = node as? Renderable {
      if renderNode.camera == nil {
        renderNode.camera = camera
      }
    }

    nodeSet.insert(node)
  }

  public func removeNode<T: GENode>(node: T?) -> T? {
    guard let node = node else { return nil }
    return nodeSet.remove(node) as? T
  }
}
