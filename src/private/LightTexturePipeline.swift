//
//  LightTexturePipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import MetalPerformanceShaders

final class LightTexturePipeline: MPSUnaryImageKernel, Pipeline {
  private struct Constants {
    static let Function = "bump"
  }

  private let pipeline: MTLComputePipelineState
  private let sampler: MTLSamplerState

  init(device: Device = Device.shared) {
    sampler = LightTexturePipeline.createSamplerState(device.device)
    pipeline = LightTexturePipeline.createPipelineState(device.device)!

    super.init(device: device.device)
  }
}

extension LightTexturePipeline {
  static func createSamplerState(device: MTLDevice) -> MTLSamplerState {
    let descriptor = MTLSamplerDescriptor()
    descriptor.normalizedCoordinates = true
    return device.newSamplerStateWithDescriptor(descriptor)
  }

  static func createPipelineState(device: MTLDevice) -> MTLComputePipelineState? {
    let library = LightTexturePipeline.getLibrary(device)

    let function = LightTexturePipeline.newFunction(library, functionName: Constants.Function)

    do {
      return try device.newComputePipelineStateWithFunction(function)
    }
    catch {
      fatalError("Unable to create compute pipeline state.")
    }
  }

  override func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer,
                                      sourceTexture: MTLTexture,
                                      destinationTexture destTexture: MTLTexture) {
    let threadsPerGroup = MTLSize(width: 16, height: 16, depth: 1)

    let widthInGroup = (destTexture.width + threadsPerGroup.width - 1) / threadsPerGroup.width
    let heightInGroup = (destTexture.height + threadsPerGroup.height - 1) / threadsPerGroup.height
    let threadsPerGrid = MTLSize(width: widthInGroup, height: heightInGroup, depth: 1)
    let encoder = commandBuffer.computeCommandEncoder()
    encoder.setComputePipelineState(pipeline)
    encoder.setTexture(sourceTexture, atIndex: 0)
    encoder.setTexture(destTexture, atIndex: 1)
    encoder.setSamplerState(sampler, atIndex: 0)
    encoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
    encoder.endEncoding()
  }
}
