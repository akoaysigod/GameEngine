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
  private weak var metalLayer: CAMetalLayer?
  private var timer: CADisplayLink!
  private var timestamp: CFTimeInterval = 0.0

  public var clearColor: Color = .black
  public var paused = true

  private var renderer: Renderer!
  private var renderPassQueue: RenderPassQueue!

  /// tmp until this is converted back to a UIView
  public var size: Size {
    let cgsize = frame.size
    return Size(width: Float(cgsize.width), height: Float(cgsize.height))
  }
  public var rect: Rect {
    return Rect(origin: Point(x: Float(frame.origin.x), y: Float(frame.origin.y)), size: size)
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
    scene.view = self
    scene.didMoveToView(self)
    paused = false
    timer.addToRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }
}

// MARK: Rendering setup
extension GameView {
  public override class func layerClass() -> AnyClass { return CAMetalLayer.self }

  var currentDrawable: CAMetalDrawable? {
    return metalLayer?.nextDrawable()
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

    setupRendering(device)

    timer = CADisplayLink(target: self, selector: #selector(newFrame(_:)))
  }

  func setupRendering(device: MTLDevice) {
    renderer = Renderer(device: device)

    let size = getNewSize()
    let width = Int(size.width)
    let height = Int(size.height)
    renderPassQueue = RenderPassQueue(depthTexture: RenderPassQueue.createDepthTexture(width, height: height, device: device))
  }
}

// MARK: Update
extension GameView {
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

    let nodes = scene.allNodes
    if !paused {
      nodes.forEach { node in
        node.update(delta)
      }

      scene.update(delta)
    }
    render(delta, nodes: nodes)
  }

  func render(delta: CFTimeInterval, nodes: Nodes) {
    let renderables = nodes.flatMap { node -> Renderables in
      if let renderable = node as? Renderable {
        return [renderable]
      }
      return []
    }

    autoreleasepool {
      renderer.render(renderPassQueue.next(self), renderables: renderables)
    }
  }

  func getNewSize() -> CGSize {
    var size = bounds.size
    size.width *= contentScaleFactor
    size.height *= contentScaleFactor
    return size
  }

  func updateDrawableSize() {
    let newSize = getNewSize()
    let width = Int(newSize.width)
    let height = Int(newSize.height)
    renderPassQueue.updateDepthTexture(width, height: height, device: device)
    metalLayer?.drawableSize = newSize
  }
}