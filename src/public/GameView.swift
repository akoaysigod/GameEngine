//
//  GameView.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import QuartzCore

//TODO: switch this back to a a regular UIView and layer setup using CADisplayLink

/**
 A `GameView` is a subclass of MTKView in order to tie into some of logic/delegate stuff provided for free by Apple. 
 */
public class GameView: UIView {
  private var currentScene: Scene?

  private(set) var device: MTLDevice!
  public override class func layerClass() -> AnyClass { return CAMetalLayer.self }
  private weak var metalLayer: CAMetalLayer?
  private var timer: CADisplayLink!

  public var clearColor: Color = .black
  public var paused = true

  private var drawable: CAMetalDrawable?
  var currentDrawable: CAMetalDrawable? {
    if drawable == nil {
      drawable = metalLayer?.nextDrawable()
    }
    return drawable
  }
  private var renderer: Renderer!

  /// tmp until this is converted back to a UIView
  public var size: Size {
    let cgsize = frame.size
    return Size(width: Float(cgsize.width), height: Float(cgsize.height))
  }
  public var rect: Rect {
    return Rect(origin: Point(x: Float(frame.origin.x), y: Float(frame.origin.y)), size: size)
  }

  func sharedInit() {
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("Metal not supported.")
    }
    self.device = device

    metalLayer = layer as? CAMetalLayer
    metalLayer?.device = device
    metalLayer?.pixelFormat = .BGRA8Unorm
    metalLayer?.framebufferOnly = true
    metalLayer?.frame = frame

    renderer = Renderer(view: self)

    timer = CADisplayLink(target: self, selector: #selector(newFrame(_:)))
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    sharedInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    sharedInit()
  }

  public func presentScene(scene: Scene) {
    currentScene = scene
    scene.didMoveToView(self)
    paused = false
    timer.addToRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }

  var timestamp: CFTimeInterval = 0.0
  func newFrame(displayLink: CADisplayLink) {
    if timestamp == 0.0 {
      timestamp = displayLink.timestamp
    }

    let delta = displayLink.timestamp - self.timestamp
    //not sure how to deal with this if you hit a break point the timer gets off making it difficult to figure out what's going on
    #if DEBUG
//    if showFPS {
//      let comeBackToThis = 1
      //need to figure out how to "animate" text changes for this singular purpose

//      let time = delta > 0.0 ? elapsedTime : 1.0
//      currentScene.fpsText.text = "\(Int(1.0 / time))"
//      currentScene.fpsText.buildMesh(device!)
//      currentScene.fpsText.updateVertices(device!)
//    }
//
//    if delta >= 0.02 {
//      delta = 1.0 / 60.0
//    }
    #endif
    
    timestamp = displayLink.timestamp

    guard let scene = currentScene else {
      return
    }

    let nodes = scene.getAllNodes()
    if !paused {
      nodes.forEach { node in
        node.update(delta)
      }

      scene.update(delta)
    }
    render(delta, nodes: nodes)
  }

  func render(delta: CFTimeInterval, nodes: Nodes) {
    let drawables = nodes.flatMap { node -> Renderables in
      if let renderable = node as? Renderable {
        return [renderable]
      }
      return []
    }

    autoreleasepool {
      renderer.render(drawables)
      drawable = nil
    }
  }
}
