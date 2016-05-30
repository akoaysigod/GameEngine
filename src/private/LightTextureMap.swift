//
//  LightTextureMap.swift
//  GameEngine
//
//  Created by Anthony Green on 5/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import MetalPerformanceShaders

final class LightTextureMap: MPSUnaryImageKernel, Pipeline {
  private struct Constants {
    static let Function = "function"
  }

  private let pipeline: MTLComputePipelineState
  private let sampler: MTLSamplerState

  init(device: Device = Device.shared) {
    sampler = LightTextureMap.createSamplerState(device.device)
    pipeline = LightTextureMap.createPipelineState(device.device)!

    super.init(device: device.device)
  }
}

extension LightTextureMap {
  static func createSamplerState(device: MTLDevice) -> MTLSamplerState {
    let descriptor = MTLSamplerDescriptor()
    descriptor.normalizedCoordinates = true
    return device.newSamplerStateWithDescriptor(descriptor)
  }

  static func createPipelineState(device: MTLDevice) -> MTLComputePipelineState? {
    let library = LightTextureMap.getLibrary(device)

    let function = LightTextureMap.newFunction(library, functionName: Constants.Function)

    do {
      return try device.newComputePipelineStateWithFunction(function)
    }
    catch {
      fatalError("Unable to create compute pipeline state.")
    }
  }
}
