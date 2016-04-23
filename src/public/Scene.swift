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

public class Scene: Node {
  private var metalLayer: CAMetalLayer!
  private var renderer: Renderer!

  private var nodeSet = Set<Node>()

  var visible = false
  var uniqueID = "1"

  private var device: MTLDevice!

  #if DEBUG
  var debugCamera: Camera
  var fpsText: TextNode
  #endif

  public override var parent: Node? {
    return nil
  }

  public override init(size: CGSize) {

    #if DEBUG
      self.debugCamera = Camera(size: size)
      self.fpsText = TextNode(text: "00", font: UIFont.systemFontOfSize(16), color: UIColor.whiteColor())
      fpsText.name = "FPS Debug text"
      //fpsText.position = (300, 0)
      fpsText.camera = debugCamera
    #endif

    //nodeSet.insert(camera)
    
    super.init(size: size)

    self.name = "scene"
    self.camera = Camera(size: size)
  }

  //why is this like this again?
  //why not just pass the view to the init?
  func setupRenderer(view: GameView) {
    self.device = view.device!
    self.renderer = Renderer(view: view)
    Fonts.cache.device = self.device

    #if DEBUG
    //addNode(fpsText)
    #endif
  }
  
  public func update(timeSinceLastUpdate: CFTimeInterval) {
    let nodes = getAllNodes()

    nodes.forEach { node in
      node.updateWithDelta(timeSinceLastUpdate)
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
