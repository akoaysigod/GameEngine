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

  private let device: MTLDevice
  private var depthTexture: MTLTexture

  private var currentWidth: Int
  private var currentHeight: Int

  private var currentDescriptorIndex = 0

  private let colorAttachmentCount = 3

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

    updateColorAttachments(width: currentWidth, height: currentHeight)
  }

  static func createDepthTexture(width: Int, height: Int, device: MTLDevice) -> MTLTexture {
    let depthTexDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: width, height: height, mipmapped: false)
    depthTexDesc.storageMode = .private
    depthTexDesc.usage = .renderTarget
    return device.makeTexture(descriptor: depthTexDesc)!
  }

  private func updateDepthTexture(width: Int, height: Int) {
    depthTexture = RenderPassQueue.createDepthTexture(width: width, height: height, device: device)
  }

  private func updateColorAttachments(width: Int, height: Int) {
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

  func next(drawable: CAMetalDrawable?, clearColor: MTLClearColor) -> NextRenderPass {
    return {
      guard let drawable = drawable else { return nil }

      let colorAttachment = MTLRenderPassColorAttachmentDescriptor()
      colorAttachment.texture = drawable.texture
      colorAttachment.clearColor = clearColor
      colorAttachment.loadAction = .clear
      colorAttachment.storeAction = .store

      if drawable.texture.width != self.currentWidth || drawable.texture.height != self.currentHeight {
        self.currentWidth = drawable.texture.width
        self.currentHeight = drawable.texture.height

        self.updateDepthTexture(width: self.currentWidth, height: self.currentHeight)
        self.updateColorAttachments(width: self.currentWidth, height: self.currentHeight)
      }

      self.renderPassDescriptor.colorAttachments[0] = colorAttachment

      return (self.renderPassDescriptor, drawable)
    }
  }
}
