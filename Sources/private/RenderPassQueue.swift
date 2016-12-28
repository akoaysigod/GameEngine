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
  fileprivate let renderPassDescriptor: MTLRenderPassDescriptor

  fileprivate let device: MTLDevice
  fileprivate var depthTexture: MTLTexture

  fileprivate var currentWidth: Int
  fileprivate var currentHeight: Int

  fileprivate var currentDescriptorIndex = 0

  fileprivate let colorAttachmentCount = 3

  init(device: Device, depthTexture: MTLTexture) {
    self.device = device.device
    self.depthTexture = depthTexture
    
    renderPassDescriptor = MTLRenderPassDescriptor()

    renderPassDescriptor.depthAttachment.texture = depthTexture
    renderPassDescriptor.depthAttachment.loadAction = .clear
    renderPassDescriptor.depthAttachment.clearDepth = 0.0
    renderPassDescriptor.depthAttachment.storeAction = .store

    currentWidth = depthTexture.width
    currentHeight = depthTexture.height

    updateColorAttachments(currentWidth, height: currentHeight)
  }

  static func createDepthTexture(_ width: Int, height: Int, device: MTLDevice) -> MTLTexture {
    let depthTexDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: width, height: height, mipmapped: false)
    depthTexDesc.storageMode = .private
    depthTexDesc.usage = .renderTarget
    return device.makeTexture(descriptor: depthTexDesc)
  }

  fileprivate func updateDepthTexture(_ width: Int, height: Int) {
    depthTexture = RenderPassQueue.createDepthTexture(width, height: height, device: device)
  }

  fileprivate func updateColorAttachments(_ width: Int, height: Int) {
    (1..<colorAttachmentCount).forEach {
      let texDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                             width: width,
                                                             height: height,
                                                             mipmapped: false)
      texDesc.usage = .renderTarget
      let tex = self.device.makeTexture(descriptor: texDesc)

      let colorAttachment = MTLRenderPassColorAttachmentDescriptor()
      colorAttachment.texture = tex
      colorAttachment.clearColor = Color.black.clearColor
      colorAttachment.loadAction = .clear
      colorAttachment.storeAction = .dontCare

      self.renderPassDescriptor.colorAttachments[$0] = colorAttachment
    }
  }

  func next(_ view: GameView) -> NextRenderPass {
    return {
      guard let drawable = view.currentDrawable else { return nil }

      let colorAttachment = MTLRenderPassColorAttachmentDescriptor()
      colorAttachment.texture = drawable.texture
      colorAttachment.clearColor = view.clearColor.clearColor
      colorAttachment.loadAction = .clear
      colorAttachment.storeAction = .store

      if drawable.texture.width != self.currentWidth || drawable.texture.height != self.currentHeight {
        self.currentWidth = drawable.texture.width
        self.currentHeight = drawable.texture.height

        self.updateDepthTexture(self.currentWidth, height: self.currentHeight)
        self.updateColorAttachments(self.currentWidth, height: self.currentHeight)
      }

      self.renderPassDescriptor.colorAttachments[0] = colorAttachment

      return (self.renderPassDescriptor, drawable)
    }
  }
}
