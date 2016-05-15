//
//  GEBufferQueue.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal


final class BufferQueue {
  let uniformBuffer: MTLBuffer
  let instanceBuffer: MTLBuffer

  private var currentBuffer = 0

  init(device: MTLDevice = Device.shared.device) {
    uniformBuffer = device.newBufferWithLength(sizeof(Uniforms) * BUFFER_SIZE, options: .CPUCacheModeDefaultCache)
    instanceBuffer = device.newBufferWithLength(sizeof(InstanceUniforms) * BUFFER_SIZE, options: .CPUCacheModeDefaultCache)
  }

  private func updateBuffer(buffer: MTLBuffer, size: Int, data: UnsafeMutablePointer<Void>) {
    let offset = currentBuffer * size
    let pointer = buffer.contents().advancedBy(offset)
    memcpy(pointer, data, size)
  }

  private func updateBuffers(uniforms: Uniforms, instanceUniforms: InstanceUniforms) {
    var uniforms = uniforms
    withUnsafeMutablePointer(&uniforms) { pointer in
      updateBuffer(uniformBuffer, size: sizeof(Uniforms), data: pointer)
    }

    var instanceUniforms = instanceUniforms
    withUnsafeMutablePointer(&instanceUniforms) { pointer in
      updateBuffer(instanceBuffer, size: sizeof(InstanceUniforms), data: pointer)
    }
  }

  func next(uniforms: Uniforms, instanceUniforms: InstanceUniforms) -> (uniformOffset: Int, instanceOffset: Int) {
    updateBuffers(uniforms, instanceUniforms: instanceUniforms)
    currentBuffer = (currentBuffer + 1) % BUFFER_SIZE

    return (currentBuffer * sizeof(Uniforms), currentBuffer * sizeof(InstanceUniforms))
  }
}
