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

  var inflightSemaphore: dispatch_semaphore_t

  init(device: MTLDevice, dataSize: Int = 0) {
    assert(dataSize > 0, "The size of the buffer should be greater than 0.")

    self.dataSize = dataSize

    let bufferSize = self.dataSize * self.size
    buffer = device.newBufferWithLength(bufferSize, options: [])

    inflightSemaphore = dispatch_semaphore_create(size)
  }

  private func updateBuffer(uniforms: Uniforms) {
    let offset = currentBuffer * dataSize
    let contents = buffer.contents()
    let pointer = UnsafeMutablePointer<Uniforms>(contents + offset)

    var uniforms = uniforms
    memcpy(pointer, &uniforms, dataSize)
  }

  func next(commandBuffer: MTLCommandBuffer, uniforms: Uniforms) -> Int {
    dispatch_semaphore_wait(inflightSemaphore, DISPATCH_TIME_FOREVER)
    commandBuffer.addCompletedHandler { [weak self] (_) -> Void in
      guard let strongSelf = self else { return }
      dispatch_semaphore_signal(strongSelf.inflightSemaphore)
    }
    updateBuffer(uniforms)
    currentBuffer = (currentBuffer + 1) % size
    return currentBuffer * dataSize
  }

  deinit {
    (0...size).forEach { _ in
      dispatch_semaphore_signal(inflightSemaphore)
    }
  }
}
