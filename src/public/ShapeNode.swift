//
//  Rect.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import UIKit

/**
 A `ShapeNode` is a node for creating colored shapes. Currently only supports rectangular shapes.
 */
public class ShapeNode: Node, Renderable {
  public var color: Color
  public var alpha: Float {
    get { return color.alpha }
    set {
      color = Color(color.red, color.green, color.blue, newValue)
    }
  }
  
  public var texture: Texture? = nil

  public let vertexBuffer: MTLBuffer
  public let indexBuffer: MTLBuffer
  let uniformBufferQueue: BufferQueue

  public var hidden = false
  public let isVisible = true

  /**
   Designated initializer. Creates a rectangular shape node of a given color.

   - parameter width:  The width of the shape.
   - parameter height: The height of the shape.
   - parameter color:  The color of the shape.

   - returns: A new instance of a rectangular `ShapeNode`.
   */
  public init(width: Float, height: Float, color: Color) {
    self.color = color

    let (vertexBuffer, indexBuffer) = ShapeNode.setupBuffers([Quad.rect(width, height)], device: Device.shared.device)
    self.vertexBuffer = vertexBuffer
    self.indexBuffer = indexBuffer

    self.uniformBufferQueue = BufferQueue(device: Device.shared.device, dataSize: sizeof(Uniforms))

    super.init(size: Size(width: width, height: height))
  }

  /**
   Convenience init. Creates a rectangular shape node of a given color.
   
   - discussion: Most of this engine uses `Float` but Swift likes to default numbers to `Doubles`.

   - parameter width:  The width of the shape.
   - parameter height: The height of the shape.
   - parameter color:  The color of the shape.

   - returns: A new instance of `ShapeNode`.
   */
  public convenience init<T: FloatLiteralConvertible>(width: T, height: T, color: Color) {
    self.init(width: width, height: height, color: color)
  }

  /**
   Convenience initializer. Creates a rectangular shape node of a given color.
   
   - parameter size:  The size of the shape.
   - parameter color: The color of the shape.

   - returns: A new instance of a rectangular `ShapeNode`.
   */
  public convenience init(size: Size, color: Color) {
    self.init(width: Float(size.width), height: Float(size.height), color: color)
  }
}

extension ShapeNode {
  public func draw(renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState? = nil) {
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
  
    let uniforms = Uniforms(projection: camera!.projection, view: camera!.view, model: decompose(), color: color.vec4)
  
    let offset = uniformBufferQueue.next(uniforms)
    renderEncoder.setVertexBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    renderEncoder.setFragmentBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 0)
  
    renderEncoder.drawIndexedPrimitives(.Triangle, indexCount: indexBuffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0)
  }
}
