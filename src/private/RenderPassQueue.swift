//
//  GERenderPassQueue.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class RenderPassQueue {
  private let view: GEView
  var queue: [MTLRenderPassDescriptor]
  var depthTex: MTLTexture?

  var currentDrawable: CAMetalDrawable? {
    return self.view.currentDrawable
  }

  private var currentDescriptorIndex = 0

  init(view: GEView, queueSize: Int = 3) {
    self.view = view
    self.queue = [MTLRenderPassDescriptor]()

    assert(queueSize >= 1, "Need at least 1 MTLRenderPassDescriptor.")
    
    let scale = UIScreen.mainScreen().nativeScale
    let size = UIScreen.mainScreen().bounds.size
    
    let width = Int(scale * size.width)
    let height = Int(scale * size.height)
    let depthTextDesc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.Depth32Float, width: width, height: height, mipmapped: false)
    self.depthTex = self.view.device?.newTextureWithDescriptor(depthTextDesc)
    
    let firstPass = MTLRenderPassDescriptor()
    firstPass.colorAttachments[0].loadAction = .Clear
    if let backgroundColor = view.backgroundColor {
      firstPass.colorAttachments[0].clearColor = backgroundColor.clearColor
    }
    else {
      firstPass.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1.0)
    }
    firstPass.colorAttachments[0].storeAction = .Store
    
    firstPass.depthAttachment.loadAction = .Clear
    firstPass.depthAttachment.clearDepth = 0.0
    firstPass.depthAttachment.storeAction = .Store

    self.queue.append(firstPass)

    (1..<queueSize).forEach { i in
      let passDescriptor = createPassDescriptor(i >= queueSize)
      self.queue.append(passDescriptor)
    }
  }

  func createPassDescriptor(isLastPass: Bool) -> MTLRenderPassDescriptor {
    let passDescriptor = MTLRenderPassDescriptor()
    passDescriptor.colorAttachments[0].loadAction = .Load
    passDescriptor.colorAttachments[0].storeAction = isLastPass ? .DontCare : .Store
    
    passDescriptor.depthAttachment.loadAction = .Load
    passDescriptor.depthAttachment.storeAction = isLastPass ? .DontCare: .Store

    return passDescriptor
  }

  func next() -> MTLRenderPassDescriptor {
    let descriptor = queue[self.currentDescriptorIndex]
    descriptor.colorAttachments[0].texture = self.currentDrawable?.texture
    descriptor.depthAttachment.texture = self.depthTex

    self.currentDescriptorIndex = (self.currentDescriptorIndex + 1) % self.queue.count

    return descriptor
  }
}
