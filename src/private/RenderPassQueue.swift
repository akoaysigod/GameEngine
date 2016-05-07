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

final class RenderPassQueue {
  private let view: GameView
  var queue: [MTLRenderPassDescriptor]
  let depthTex: MTLTexture
  let renderPassDescriptor: MTLRenderPassDescriptor

  var currentDrawable: CAMetalDrawable? {
    return view.currentDrawable
  }

  private var currentDescriptorIndex = 0

  init(view: GameView, queueSize: Int = 3) {
    self.view = view
    self.queue = [MTLRenderPassDescriptor]()

    assert(queueSize >= 1, "Need at least 1 MTLRenderPassDescriptor.")

    //this won't work in OSX since the window can be resized
    //apple creates this stuff somewhat lazily on the first render
    //and then updates it if it's necessary like if the screen size changes
    let scale = UIScreen.mainScreen().nativeScale
    let size = UIScreen.mainScreen().bounds.size
    
    let width = Int(scale * size.width)
    let height = Int(scale * size.height)
    let depthTextDesc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.Depth32Float, width: width, height: height, mipmapped: false)
    depthTex = view.device.newTextureWithDescriptor(depthTextDesc)
    
    renderPassDescriptor = MTLRenderPassDescriptor()


//    renderPassDescriptor.colorAttachments[0].loadAction = .Clear
//    renderPassDescriptor.colorAttachments[0].clearColor = view.clearColor.clearColor
//
//    renderPassDescriptor.colorAttachments[0].storeAction = .Store

    renderPassDescriptor.depthAttachment.texture = depthTex
    renderPassDescriptor.depthAttachment.loadAction = .Clear
    renderPassDescriptor.depthAttachment.clearDepth = 0.0
    renderPassDescriptor.depthAttachment.storeAction = .Store

//    (1..<queueSize - 1).forEach { i in
//      renderPassDescriptor.colorAttachments[i].loadAction = .Load
//      renderPassDescriptor.colorAttachments[i].storeAction = .Store
//    }
//    renderPassDescriptor.colorAttachments[queueSize - 1].loadAction = .Load
//    renderPassDescriptor.colorAttachments[queueSize - 1].storeAction = .DontCare

//    self.queue.append(renderPassDescriptor)

//    (1..<queueSize).forEach { i in
//      let passDescriptor = createPassDescriptor(i, isLastPass: i >= queueSize)
//      //self.queue.append(passDescriptor)
//      renderPassDescriptor.colorAttachments[i] = passDescriptor
//    }
  }

  func createPassDescriptor(index: Int, isLastPass: Bool) -> MTLRenderPassDescriptor {
    let passDescriptor = MTLRenderPassDescriptor()
    passDescriptor.colorAttachments[index].loadAction = .Load
    passDescriptor.colorAttachments[index].storeAction = isLastPass ? .DontCare : .Store
    
    passDescriptor.depthAttachment.loadAction = .Load
    passDescriptor.depthAttachment.storeAction = isLastPass ? .DontCare: .Store

    return passDescriptor
  }

  func next() -> (MTLRenderPassDescriptor, MTLDrawable)? {
    guard let drawable = currentDrawable else { return nil }

    let colorAttachment = MTLRenderPassColorAttachmentDescriptor()
    colorAttachment.texture = drawable.texture
    colorAttachment.clearColor = view.clearColor.clearColor
    colorAttachment.loadAction = .Clear
    colorAttachment.storeAction = .Store

    renderPassDescriptor.colorAttachments[0] = colorAttachment
//    let descriptor = queue[self.currentDescriptorIndex]
//    descriptor.colorAttachments[0].texture = self.currentDrawable?.texture
//    descriptor.depthAttachment.texture = self.depthTex
//
//    self.currentDescriptorIndex = (self.currentDescriptorIndex + 1) % self.queue.count

    return (renderPassDescriptor, drawable)
  }
}
