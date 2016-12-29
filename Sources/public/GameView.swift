//
//  GameView.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import QuartzCore

#if os(iOS)
  import UIKit
  public typealias V = UIView
#else
  import Cocoa
  public typealias V = NSView
#endif

/**
 A `GameView` is a subclass of MTKView in order to tie into some of logic/delegate stuff provided for free by Apple.
 */
open class GameView: V {
  fileprivate var currentScene: Scene?

  fileprivate(set) var projection: Projection!

  fileprivate(set) var device: MTLDevice
  fileprivate weak var metalLayer: CAMetalLayer?

  private var updater: Updater!

  /// The background color of the view, ignore the backgroundColor property for now it doesn't do anything but might someday
  public var clearColor: Color = .black
  /// Pauses rendering, automatically starts when a scene is presented
  public var paused = true

  let bufferManager: BufferManager
  fileprivate let renderer: Renderer
  fileprivate let renderPassQueue: RenderPassQueue

  #if !os(macOS)
    open static override var layerClass: AnyClass { return CAMetalLayer.self }
  #else
    open override func makeBackingLayer() -> CALayer { return CAMetalLayer() }
  #endif

  override init(frame: CGRect) {
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("Metal not supported.")
    }
    self.device = device

    let width = Int(frame.size.width)
    let height = Int(frame.size.height)
    renderPassQueue = RenderPassQueue(device: Device.shared, depthTexture: RenderPassQueue.createDepthTexture(width, height: height, device: device))

    projection = Projection(size: Size(width: width, height: height))
    bufferManager = BufferManager(projection: projection.projection)
    renderer = Renderer(device: device, bufferManager: bufferManager)

    super.init(frame: frame)

    #if os(macOS)
      wantsLayer = true
    #endif

    metalLayer = layer as? CAMetalLayer
    metalLayer?.device = device
    metalLayer?.pixelFormat = .bgra8Unorm
    metalLayer?.framebufferOnly = true
    metalLayer?.frame = frame

    updater = Updater(gameView: self)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func presentScene(_ scene: Scene) {
    currentScene = scene
    scene.view = self
    scene.didMoveToView(self)
    paused = false
  }
}

// MARK: Update
extension GameView {
  var currentDrawable: CAMetalDrawable? {
    return metalLayer?.nextDrawable()
  }

  func update(delta: Double) {
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

//  fileprivate func getNewSize() -> CGSize {
//    return Screen.main.nativeBounds.size
//    var size = bounds.size
//    //this should be nativeScale from UIScreen I have no idea why it's this or when this stopped being correct?
//    //tmp
//    #if os(iOS)
//    size.width *= contentScaleFactor
//    size.height *= contentScaleFactor
//    #endif
//    return size
//  }

  //not currently being used for anything
  fileprivate func updateDrawableSize() {
    let newSize = Screen.main.nativeBounds.size
    metalLayer?.drawableSize = newSize

    projection.update(newSize.size)
    bufferManager.updateProjection(projection.projection)
    currentScene?.updateCameras(newSize.size)
  }
}
