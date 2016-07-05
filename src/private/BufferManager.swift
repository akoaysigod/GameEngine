//
//  BufferManager.swift
//  GameEngine
//
//  Created by Anthony Green on 5/29/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal

final class BufferManager {
  private let device: MTLDevice

  private let startSize = 500

  let uniformBuffer: Buffer
  let uiUniformBuffer: Buffer

  let shapeIndexBuffer: Buffer
  let shapeVertexBuffer: Buffer

  private(set) var indexBuffer: Buffer

  private var vertexBuffer = [Int: Buffer]()

  init(projection: Mat4, device: Device = Device.shared) {
    self.device = device.device

    uniformBuffer = Buffer(length: sizeof(Mat4) * 2)
    uniformBuffer.addData([projection], size: sizeof(Mat4))
    uiUniformBuffer = Buffer(length: sizeof(Mat4) * 2)
    uiUniformBuffer.addData([projection], size: sizeof(Mat4)) //do I still need this?

    indexBuffer = Buffer(length: Quad.indicesSize * startSize)
    let (indexData, size) = Quad.indices(startSize)
    indexBuffer.addData(indexData, size: size)

    shapeIndexBuffer = Buffer(length: Quad.indicesSize)
    shapeIndexBuffer.addData(Array(indexData[0..<6]), size: Quad.indicesSize)

    shapeVertexBuffer = Buffer(length: Quad.size)
  }

  subscript(index: Int) -> Buffer? {
    get {
      return vertexBuffer[index]
    }
    set {
      vertexBuffer[index] = newValue
    }
  }

  func updateProjection(projection: Mat4) {
    uniformBuffer.addData([projection], size: sizeof(Mat4))
    uiUniformBuffer.addData([projection], size: sizeof(Mat4))
  }
}
