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

public class GEColorRect: GENode, Renderable {
  public var color = UIColor.whiteColor()
  
  var texture: GETexture? = nil

  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer
  let uniformBufferQueue: BufferQueue

  init(size: CGSize, color: UIColor) {
    self.color = color

    let (vertexBuffer, indexBuffer) = GEColorRect.setupBuffers([Quad.rect(size.w, size.h)], device: Device.shared.device)
    self.vertexBuffer = vertexBuffer
    self.indexBuffer = indexBuffer

    self.uniformBufferQueue = BufferQueue(device: Device.shared.device, dataSize: sizeof(Uniforms))

    super.init(size: size)
  }

  convenience init(width: Double, height: Double, color: UIColor) {
    self.init(size: CGSize(width: width, height: height), color: color)
  }
}
