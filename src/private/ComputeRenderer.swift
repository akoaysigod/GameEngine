//
//  ComputeRenderer.swift
//  GameEngine
//
//  Created by Anthony Green on 5/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal
import MetalPerformanceShaders

final class ComputeRenderer {
  private let device: MTLDevice
  private let srcTexture: MTLTexture
  private let destTexture: MTLTexture

  private let commandQueue: MTLCommandQueue

  init(srcTexture: Texture, device: Device = Device.shared) {
    self.device = device.device
    self.srcTexture = srcTexture.texture

    destTexture = self.device.newTextureWithDescriptor(self.srcTexture.descriptor)
    commandQueue = self.device.newCommandQueue()
    commandQueue.label = "compute command queue"
  }

  func generateTexture() -> Texture {
    let pipeline = LightTexturePipeline()
    let commandBuffer = commandQueue.commandBuffer()

    pipeline.encodeToCommandBuffer(commandBuffer,
                                   sourceTexture: srcTexture,
                                   destinationTexture: destTexture)
    commandBuffer.commit()

    return Texture(texture: destTexture)
  }
}

private extension MTLTexture {
  var descriptor: MTLTextureDescriptor {
    let d = MTLTextureDescriptor()

    d.textureType = textureType
    d.pixelFormat = pixelFormat
    d.width = width
    d.height = height
    d.depth = depth
    d.mipmapLevelCount = mipmapLevelCount
    d.arrayLength = arrayLength

    d.cpuCacheMode = cpuCacheMode
    d.storageMode = storageMode
    d.usage = usage

    return d
  }
}
