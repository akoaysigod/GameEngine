//
//  ComputeRenderer.swift
//  GameEngine
//
//  Created by Anthony Green on 5/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal
//import MetalPerformanceShaders

//TODO: We might have to run this prior to generating the texture maps, the edge of each image is just set to black so it'll probably make things look weird

final class ComputeRenderer {
  fileprivate let device: MTLDevice
  fileprivate let srcTexture: MTLTexture
  fileprivate let destTexture: MTLTexture

  fileprivate let commandQueue: MTLCommandQueue

  init(srcTexture: Texture, device: Device = Device.shared) {
    self.device = device.device
    self.srcTexture = srcTexture.texture

    destTexture = self.device.makeTexture(descriptor: self.srcTexture.descriptor)
    commandQueue = self.device.makeCommandQueue()
    commandQueue.label = "compute command queue"
  }

  func generateTexture() -> Texture {
    let pipeline = LightTexturePipeline()
    let commandBuffer = commandQueue.makeCommandBuffer()

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
