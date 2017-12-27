//
//  LightTexturePipeline.swift
//  GameEngine
//
//  Created by Anthony Green on 5/30/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal
import simd

//https://en.wikipedia.org/wiki/Sobel_operator
private struct Convolutions {
  let dx: float2x3
  let dy: float2x3

  //Dx is left column then right column
  //Dy is top row then bottom row

  static func convolution(_ conv: float2x3) -> Convolutions {
    return Convolutions(dx: conv, dy: conv)
  }

  static var sobel: Convolutions {
    let n = float3(arrayLiteral: -1.0, -2.0, -1.0)
    let p = float3(arrayLiteral: 1.0, 2.0, 1.0)

    return convolution(float2x3([n, p]))
  }

  static var scharr: Convolutions {
    let n = float3(arrayLiteral: -3.0, -10.0, -3.0)
    let p = float3(arrayLiteral: 3.0, 10.0, 3.0)

    return convolution(float2x3([n, p]))
  }
}

final class LightTexturePipeline: Pipeline {
  fileprivate struct Constants {
    static let Function = "normal"
  }

  fileprivate let pipeline: MTLComputePipelineState
  fileprivate let sampler: MTLSamplerState

  init(device: Device = Device.shared) {
    sampler = LightTexturePipeline.createSamplerState(device.device)
    pipeline = LightTexturePipeline.createPipelineState(device.device)!
  }
}

extension LightTexturePipeline {
  static func createSamplerState(_ device: MTLDevice) -> MTLSamplerState {
    let descriptor = MTLSamplerDescriptor()
    descriptor.sAddressMode = .clampToEdge
    descriptor.tAddressMode = .clampToEdge
    descriptor.normalizedCoordinates = false
    return device.makeSamplerState(descriptor: descriptor)!
  }

  static func createPipelineState(_ device: MTLDevice) -> MTLComputePipelineState? {
    let library = LightTexturePipeline.getLibrary(device)

    let function = LightTexturePipeline.newFunction(library, functionName: Constants.Function)

    do {
      return try device.makeComputePipelineState(function: function)
    }
    catch {
      fatalError("Unable to create compute pipeline state.")
    }
  }

  func encodeToCommandBuffer(_ commandBuffer: MTLCommandBuffer,
                             sourceTexture: MTLTexture,
                             destinationTexture destTexture: MTLTexture) {
    let threadsPerGroup = MTLSize(width: 16, height: 16, depth: 1)

    let widthInGroup = (destTexture.width + threadsPerGroup.width - 1) / threadsPerGroup.width
    let heightInGroup = (destTexture.height + threadsPerGroup.height - 1) / threadsPerGroup.height
    let threadsPerGrid = MTLSize(width: widthInGroup, height: heightInGroup, depth: 1)
    let encoder = commandBuffer.makeComputeCommandEncoder()
    encoder?.setComputePipelineState(pipeline)
    encoder?.setTexture(sourceTexture, index: 0)
    encoder?.setTexture(destTexture, index: 1)
    encoder?.setSamplerState(sampler, index: 0)

    var convolutions = Convolutions.scharr
    encoder?.setBytes(&convolutions, length: MemoryLayout<Convolutions>.size, index: 0)

    encoder?.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
    encoder?.endEncoding()
  }
}
