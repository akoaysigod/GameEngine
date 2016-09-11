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
open class GameView: UIView {
  fileprivate var currentScene: Scene?

  fileprivate(set) var projection: Projection!

  fileprivate(set) var device: MTLDevice!
  fileprivate weak var metalLayer: CAMetalLayer?
  fileprivate var timer: CADisplayLink!
  fileprivate var timestamp: CFTimeInterval = 0.0

  open var clearColor: Color = .black
  open var paused = true

  fileprivate(set) var bufferManager: BufferManager!
  fileprivate var renderer: Renderer!
  fileprivate var renderPassQueue: RenderPassQueue!

  /// tmp until this is converted back to a UIView
  open var size: Size {
    let cgsize = frame.size
    return Size(width: Float(cgsize.width), height: Float(cgsize.height))
  }
  open var rect: Rect {
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

  open func presentScene(_ scene: Scene) {
    currentScene = scene
    scene.view = self
    scene.didMoveToView(self)
    paused = false
    timer.add(to: .main(), forMode: RunLoopMode.commonModes)
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

  func setupRendering(_ device: MTLDevice) {
    let size = getNewSize()
    let width = Int(size.width)
    let height = Int(size.height)
    renderPassQueue = RenderPassQueue(device: Device.shared, depthTexture: RenderPassQueue.createDepthTexture(width, height: height, device: device))

    projection = Projection(size: size.size)
    bufferManager = BufferManager(projection: projection.projection)
    renderer = Renderer(device: device, bufferManager: bufferManager)
  }
}

// MARK: Update
extension GameView {
  @objc fileprivate func newFrame(_ displayLink: CADisplayLink) {
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

    if !paused {
      updateNodes(delta, nodes: scene.allNodes)
      scene.update(delta)
    }
    render(scene)
  }

  fileprivate func updateNodes(_ delta: CFTimeInterval, nodes: Nodes) {
    nodes.forEach {
      $0.update(delta)
    }
  }

  fileprivate func render(_ scene: Scene) {
    autoreleasepool {
      renderer.render(renderPassQueue.next(self), view: scene.camera.view, shapeNodes: scene.graphCache.shapeNodes, spriteNodes: scene.graphCache.spriteNodes, textNodes: scene.graphCache.textNodes, lightNodes: scene.graphCache.lightNodes)
    }
  }

  fileprivate func getNewSize() -> CGSize {
    var size = bounds.size
    size.width *= contentScaleFactor
    size.height *= contentScaleFactor
    return size
  }

  fileprivate func updateDrawableSize() {
    let newSize = getNewSize()
    metalLayer?.drawableSize = newSize

    projection.update(newSize.size)
    bufferManager.updateProjection(projection.projection)
    currentScene?.updateCameras(newSize.size)
  }
}
