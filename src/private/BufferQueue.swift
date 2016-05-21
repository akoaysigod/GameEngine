//
//  GEBufferQueue.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import simd

final class BufferQueue {
  let uniformBuffer: MTLBuffer
  private let instanceBuffer: MTLBuffer

  private var currentBuffer = 0
  let uSize = sizeof(Uniforms)
  let iSize = sizeof(InstanceUniforms)

  init(device: MTLDevice = Device.shared.device) {
    uniformBuffer = device.newBufferWithLength(sizeof(Uniforms) * BUFFER_SIZE, options: .CPUCacheModeDefaultCache)
    instanceBuffer = device.newBufferWithLength(sizeof(InstanceUniforms) * BUFFER_SIZE, options: .CPUCacheModeDefaultCache)
  }

  private func updateBuffer(buffer: MTLBuffer, size: Int, data: UnsafeMutablePointer<Void>) {
    let offset = currentBuffer * size
    //let pointer = buffer.contents()
    memcpy(buffer.contents() + offset, data, size)
  }

  private func updateBuffers(uniforms: Uniforms, instanceUniforms: InstanceUniforms) {
    var uniforms = uniforms
    memcpy(uniformBuffer.contents() + (currentBuffer * uSize), &uniforms, uSize)
    var instanceUniforms = instanceUniforms
    memcpy(instanceBuffer.contents() + (currentBuffer * iSize), &instanceUniforms, iSize)
  }

  func next(uniforms: Uniforms, instanceUniforms: InstanceUniforms) -> (uBuffer: MTLBuffer, uniformOffset: Int, iBuffer: MTLBuffer, instanceOffset: Int) {
//    if currentBuffer == 1 {
//      return (uniformBuffer, currentBuffer * uSize, instanceBuffer, currentBuffer * iSize)
//    }
    var uniforms = uniforms
    var instanceUniforms = instanceUniforms
    //updateBuffers(uniforms, instanceUniforms: instanceUniforms)
    //var uniforms = uniforms
    memcpy(uniformBuffer.contents() + (currentBuffer * uSize), &uniforms, uSize)
    //var instanceUniforms = instanceUniforms
    memcpy(instanceBuffer.contents() + (currentBuffer * iSize), &instanceUniforms, iSize)

    currentBuffer = (currentBuffer + 1) % BUFFER_SIZE

    //return (currentBuffer * uSize, currentBuffer * iSize)
    return (uniformBuffer, currentBuffer * uSize, instanceBuffer, currentBuffer * iSize)
  }
}
