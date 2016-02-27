//
//  GEView.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public class GEView: MTKView {
  private var currentScene: GEScene!
  var timer: CADisplayLink!
  
  override init(frame frameRect: CGRect, device: MTLDevice?) {
    super.init(frame: frameRect, device: device)
  }
  
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func presentScene(scene: GEScene) {
    self.currentScene = scene
    
    scene.setupRenderer(self)
    
    self.timer = CADisplayLink(target: self, selector: "newFrame:")
    self.timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }
  
  var timestamp: CFTimeInterval = 0.0
  func newFrame(displayLink: CADisplayLink) {
    if self.timestamp == 0.0 {
      self.timestamp = displayLink.timestamp
    }

    var elapsedTime = displayLink.timestamp - self.timestamp
    //not sure how to deal with this if you hit a break point the timer gets off making it difficult to figure out what's going on
    #if DEBUG
    if elapsedTime >= 0.02 {
      elapsedTime = 1.0 / 60.0
    }
    #endif
    
    self.timestamp = displayLink.timestamp

    self.currentScene.update(elapsedTime)
  }
}
