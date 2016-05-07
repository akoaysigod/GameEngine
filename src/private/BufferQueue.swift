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
  let buffer: MTLBuffer

  private let dataSize: Int
  private let size = 3
  private var currentBuffer = 0

  init(device: MTLDevice, dataSize: Int = 0) {
    assert(dataSize > 0, "The size of the buffer should be greater than 0.")

    self.dataSize = dataSize

    let bufferSize = self.dataSize * self.size
    buffer = device.newBufferWithLength(bufferSize, options: [])
  }

  private func updateBuffer(uniforms: Uniforms) {
    let offset = currentBuffer * dataSize
    let contents = buffer.contents()
    let pointer = UnsafeMutablePointer<Uniforms>(contents + offset)

    var uniforms = uniforms
    memcpy(pointer, &uniforms, dataSize)
  }

  func next(uniforms: Uniforms) -> Int {
    updateBuffer(uniforms)
    currentBuffer = (currentBuffer + 1) % size
    return currentBuffer * dataSize
  }
}
