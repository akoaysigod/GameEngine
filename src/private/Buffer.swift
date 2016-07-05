//
//  Buffer.swift
//  GameEngine
//
//  Created by Anthony Green on 5/22/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class Buffer { //might change this to a protocol 
  private var buffer: MTLBuffer
  private let length: Int

  init(length: Int, device: Device = Device.shared) {
    self.length = length
    buffer = device.device.newBufferWithLength(length * BUFFER_SIZE, options: .CPUCacheModeDefaultCache)
  }

  func addData<T>(data: [T], size: Int, offset: Int = 0) {
    memcpy(buffer.contents() + (size * offset), data, size)
    memcpy(buffer.contents() + length + (size * offset), data, size)
    memcpy(buffer.contents() + length * 2 + (size * offset), data, size)
  }

  func update<T>(data: [T], size: Int, bufferIndex: Int, offset: Int = 0) {
    #if DEBUG
      if sizeof(T) != strideof(T) {
        DLog("Possibly wrong sized data, \(T.self)")
      }
    #endif
    memcpy(buffer.contents() + offset + (bufferIndex * length), data, size)
  }

  func nextBuffer(bufferIndex: Int) -> (buffer: MTLBuffer, offset: Int) {
    return (buffer, bufferIndex * length)
  }
}
