//
//  VertexBuffer.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class VertexBuffer {
  let buffer: MTLBuffer

  init(quad: Quads, device: Device = Device.shared) {
    buffer = device.device.newBufferWithBytes(quad.vertexData, length: quad.vertexSize, options: .CPUCacheModeDefaultCache)
  }

  func updateColor(color: Color) {

  }
}
