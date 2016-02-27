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

public class GEScene {
  public var size: CGSize
  public var camera: GECamera
  
  var device: MTLDevice!
  var metalLayer: CAMetalLayer!
  var renderer: Renderer!
  var timer: CADisplayLink!
  
  var drawables: Renderables = Renderables()
  var nodes = GENodes()
  
  var visible = false
  var uniqueID = "1"

  init(size: CGSize) {
    self.size = size
    self.camera = GECamera(size: size)
  }
  
  func setupRenderer(view: GEView) {
    self.device = view.device!
    self.renderer = Renderer(view: view)
    Fonts.cache.device = self.device
  }
  
  public func update(timeSinceLastUpdate: CFTimeInterval) {
    nodes.forEach { (node) -> () in
      node.updateWithDelta(timeSinceLastUpdate)
    }

    autoreleasepool { () -> () in
      renderer.draw(self.drawables)
    }
  }
  
  public func addNode(node: GENode) {
    if let sprite = node as? GESprite {
      sprite.loadTexture(self.device)
    }

    //TODO: tmp
    if let textNode = node as? GETextLabel {
      textNode.buildMesh(device)
    }
    
    if let renderNode = node as? GERenderNode {
      renderNode.device = self.device
      if renderNode.camera == nil {
        renderNode.camera = self.camera
      }
      renderNode.setupBuffers()
      self.drawables.append(renderNode)
    }
    
    self.nodes.append(node)
  }
  
  func traverseTree(nodes: GENodes) {

  }
}
