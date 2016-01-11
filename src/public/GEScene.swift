//
//  GEScene.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Tony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal

public class GEScene: TreeNode {
  public var size: CGSize
  public var camera: GECamera
  
  var device: MTLDevice!
  var metalLayer: CAMetalLayer!
  var renderer: Renderer!
  var timer: CADisplayLink!
  
  var drawables = [GENode]()
  
  var tree: DrawTree = DrawTree()
  var visible = false
  var uniqueID = "1"
  
  init(size: CGSize) {
    self.size = size
    self.camera = GECamera(size: size)
  }
  
  func setupRenderer(view: GEView) {
    self.device = view.device!
    self.renderer = Renderer(view: view)
  }
  
  public func update(timeSinceLastUpdate: CFTimeInterval) {
    self.drawables.forEach { (node) -> () in
      node.updateWithDelta(timeSinceLastUpdate)
    }

    autoreleasepool { () -> () in
      self.renderer.draw(self.drawables)
    }
  }
  
  public func addChild(node: GENode) {
    node.device = self.device
    if node.camera == nil {
      node.camera = self.camera
    }
    
    if let sprite = node as? GESprite {
      sprite.loadTexture(self.device)
    }
    
    self.tree.addNode(nil, node: node)
    
    node.setupBuffers()
    self.drawables.append(node)
  }
  
}
