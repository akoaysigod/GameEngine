//
//  Sprite.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public class SpriteNode: Node, Renderable {
  public var color: UIColor

  public var texture: Texture?

  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer
  let uniformBufferQueue: BufferQueue

  public var isVisible = true

  public required init(texture: Texture, color: UIColor, size: CGSize) {
    //let (vertexBuffer, indexBuffer) = Sprite.setupBuffers([Quad.spriteRect(size.w, size.h)], device: Device.shared.device)
    let (vertexBuffer, indexBuffer) = SpriteNode.setupBuffers([Quad.spriteRect(texture.frame)], device: Device.shared.device)

    self.vertexBuffer = vertexBuffer
    self.indexBuffer = indexBuffer
    self.uniformBufferQueue = BufferQueue(device: Device.shared.device, dataSize: sizeof(Uniforms))

    self.texture = texture
    self.color = color

    super.init(size: texture.size)
  }

  public convenience init(texture: Texture, size: CGSize) {
    self.init(texture: texture, color: .whiteColor(), size: size)
  }

  public convenience init(texture: Texture) {
    self.init(texture: texture, color: .whiteColor(), size: texture.size)
  }

  public convenience init(named: String) {
    self.init(texture: Texture(named: named))
  }
}
