//
//  Buffer.swift
//  GameEngine
//
//  Created by Anthony Green on 5/22/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class Buffer { //might change this to a protocol 
  fileprivate var buffer: MTLBuffer
  fileprivate let length: Int

  init(length: Int, instances: Int = BUFFER_SIZE, device: Device = Device.shared) {
    self.length = length
    buffer = device.device.makeBuffer(length: length * instances, options: MTLResourceOptions())
  }

  func addData<T>(_ data: [T], size: Int, offset: Int = 0) {
    memcpy(buffer.contents() + (size * offset), data, size)
    memcpy(buffer.contents() + length + (size * offset), data, size)
    memcpy(buffer.contents() + length * 2 + (size * offset), data, size)
  }

  func update<T>(_ data: [T], size: Int, bufferIndex: Int, offset: Int = 0) {
    #if DEBUG
      if sizeof(T) != strideof(T) {
        DLog("Possibly wrong sized data, \(T.self)")
      }
    #endif
    memcpy(buffer.contents() + offset + (bufferIndex * length), data, size)
  }

  func nextBuffer(_ bufferIndex: Int) -> (buffer: MTLBuffer, offset: Int) {
    return (buffer, bufferIndex * length)
  }
}
