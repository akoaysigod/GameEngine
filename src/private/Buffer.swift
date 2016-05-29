//
//  Buffer.swift
//  GameEngine
//
//  Created by Anthony Green on 5/22/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class Buffer { //might change this to a protocol 
  private(set) var buffer: MTLBuffer

  init(length: Int, device: Device = Device.shared) {
    buffer = device.device.newBufferWithLength(length, options: .CPUCacheModeDefaultCache)
  }

  func update<T>(data: [T], size: Int, offset: Int = 0) {
    #if DEBUG
      if sizeof(T) != strideof(T) {
        DLog("Possibly wrong sized data, \(T.self)")
      }
    #endif
    memcpy(buffer.contents() + offset, data, size)
  }
}
