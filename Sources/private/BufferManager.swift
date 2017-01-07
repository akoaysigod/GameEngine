//
//  BufferManager.swift
//  GameEngine
//
//  Created by Anthony Green on 5/29/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class BufferManager {
  fileprivate let device: MTLDevice

  fileprivate let startSize = 500

  let uniformBuffer: Buffer
  let uiUniformBuffer: Buffer

  let shapeIndexBuffer: Buffer
  let shapeVertexBuffer: Buffer

  fileprivate(set) var indexBuffer: Buffer

  fileprivate var vertexBuffer = [Int: Buffer]()

  var lightVertexBuffer: Buffer?
  fileprivate let maxLights = 100

  // I need to look into this more but for whatever macOS only accepts buffers in sizes of 256?
  // this adds padding to the uniform buffer which are only 128 bytes in size 
  #if !os(macOS)
    private let uniformPad = 2
  #else
    private let uniformPad = 4
  #endif

  init(device: MTLDevice, projection: Mat4) {
    self.device = device

    uniformBuffer = Buffer(device: device, length: MemoryLayout<Mat4>.size * uniformPad)
    uniformBuffer.addData([projection], size: MemoryLayout<Mat4>.size)
    uiUniformBuffer = Buffer(device: device, length: MemoryLayout<Mat4>.size * uniformPad)
    uiUniformBuffer.addData([projection], size: MemoryLayout<Mat4>.size) //do I still need this?

    indexBuffer = Buffer(device: device, length: Quad.indicesSize * startSize)
    let (indexData, size) = Quad.indices(startSize)
    indexBuffer.addData(indexData, size: size)

    shapeIndexBuffer = Buffer(device: device, length: Quad.indicesSize)
    shapeIndexBuffer.addData(Array(indexData[0..<6]), size: Quad.indicesSize)

    shapeVertexBuffer = Buffer(device: device, length: Quad.size)

    //lightVertexBuffer = Buffer(length: maxLights * )
  }

  subscript(index: Int) -> Buffer? {
    get {
      return vertexBuffer[index]
    }
    set {
      vertexBuffer[index] = newValue
    }
  }

  func updateProjection(_ projection: Mat4) {
    uniformBuffer.addData([projection], size: MemoryLayout<Mat4>.size)
    uiUniformBuffer.addData([projection], size: MemoryLayout<Mat4>.size)
  }
}
