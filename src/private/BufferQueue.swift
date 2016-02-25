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

  init(device: MTLDevice, dataSize: Int) {
    self.dataSize = dataSize
    let bufferSize = dataSize * self.size
    self.buffer = device.newBufferWithLength(bufferSize, options: [])

    self.inflightSemaphore = dispatch_semaphore_create(self.size)
  }

  private func updateBuffer(data: Data) {
    let offset = self.currentBuffer * self.dataSize
    let contents = self.buffer.contents()
    let pointer = UnsafeMutablePointer<Float>(contents + offset)
    memcpy(pointer, data, self.dataSize)
  }

  func next(commandBuffer: MTLCommandBuffer, data: Data) -> Int {
    dispatch_semaphore_wait(self.inflightSemaphore, DISPATCH_TIME_FOREVER)
    commandBuffer.addCompletedHandler { [weak self] (_) -> Void in
      guard let strongSelf = self else { return }
      dispatch_semaphore_signal(strongSelf.inflightSemaphore)
    }
    self.updateBuffer(data)
    self.currentBuffer = (currentBuffer + 1) % self.size
    return self.currentBuffer * self.dataSize
  }

  deinit {
    for _ in 0...self.size {
      dispatch_semaphore_signal(self.inflightSemaphore)
    }
  }
}
