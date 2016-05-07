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

typealias NextRenderPass = () -> (MTLRenderPassDescriptor, MTLDrawable)?

final class RenderPassQueue {
  private let renderPassDescriptor: MTLRenderPassDescriptor
  private var depthTexture: MTLTexture

  private var currentDescriptorIndex = 0

  init(depthTexture: MTLTexture) {
    self.depthTexture = depthTexture
    
    renderPassDescriptor = MTLRenderPassDescriptor()

    renderPassDescriptor.depthAttachment.texture = depthTexture
    renderPassDescriptor.depthAttachment.loadAction = .Clear
    renderPassDescriptor.depthAttachment.clearDepth = 0.0
    renderPassDescriptor.depthAttachment.storeAction = .Store
  }

  static func createDepthTexture(width: Int, height: Int, device: MTLDevice) -> MTLTexture {
    let depthTexDesc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.Depth32Float, width: width, height: height, mipmapped: false)
    return device.newTextureWithDescriptor(depthTexDesc)
  }

  func updateDepthTexture(width: Int, height: Int, device: MTLDevice) {
    depthTexture = RenderPassQueue.createDepthTexture(width, height: height, device: device)
  }

  func next(view: GameView) -> NextRenderPass {
    return {
      guard let drawable = view.currentDrawable else { return nil }

      let colorAttachment = MTLRenderPassColorAttachmentDescriptor()
      colorAttachment.texture = drawable.texture
      colorAttachment.clearColor = view.clearColor.clearColor
      colorAttachment.loadAction = .Clear
      colorAttachment.storeAction = .Store

      self.renderPassDescriptor.colorAttachments[0] = colorAttachment

      return (self.renderPassDescriptor, drawable)
    }
  }
}
