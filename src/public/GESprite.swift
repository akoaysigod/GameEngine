//
//  GESprite.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public class GESprite: GENode, Renderable {
  public var color = UIColor.whiteColor()

  public var texture: GETexture?

  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer
  let uniformBufferQueue: BufferQueue

  public var isVisible = true

  public init(texture: GETexture) {
    let (vertexBuffer, indexBuffer) = GESprite.setupBuffers([Quad.spriteRect(texture.width, texture.height)], device: Device.shared.device)
    //let (vertexBuffer, indexBuffer) = GESprite.setupBuffers([Quad.spriteRect(64, 64)], device: Device.shared.device)
    DLog(texture.width, texture.height)

    self.vertexBuffer = vertexBuffer
    self.indexBuffer = indexBuffer
    self.uniformBufferQueue = BufferQueue(device: Device.shared.device, dataSize: color.size)

    self.texture = texture

    super.init(size: CGSize(width: texture.width, height: texture.height))
  }

  convenience init(imageName: String) {
    self.init(texture: GETexture(imageName: imageName))
  }
}
