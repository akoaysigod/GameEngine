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
  var texture: MTLTexture?

  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer
  let uniformBufferQueue: BufferQueue

  public var isVisible = true

  init(imageName: String) {
    let (imageData, size) = GESprite.imageLoader(imageName)

    self.texture = GESprite.loadTexture(imageData, device: Device.shared.device)

    let (vertexBuffer, indexBuffer) = GESprite.setupBuffers([Quad.spriteRect(size.w, size.h)], device: Device.shared.device)

    self.vertexBuffer = vertexBuffer
    self.indexBuffer = indexBuffer
    self.uniformBufferQueue = BufferQueue(device: Device.shared.device, dataSize:  FloatSize * GENode().modelMatrix.data.count)

    super.init()
  }
  
  private static func loadTexture(imageData: NSData, device: MTLDevice) -> MTLTexture {
    let textureLoader = MTKTextureLoader(device: device)

    //don't load anything weird I guess
    return try! textureLoader.newTextureWithData(imageData, options: nil)
  }

  //TODO: allow setting size in node class
  private static let errorImageName = "Test2"
  private static func imageLoader(imageName: String) -> (imageData: NSData, size: CGSize) {
    if let image = UIImage(named: imageName),
    let imageData = UIImagePNGRepresentation(image)
    {
      return (imageData, image.size)
    }

    let path = NSBundle.mainBundle().URLForResource(self.errorImageName, withExtension: "png")!
    let image = UIImage(data: NSData(contentsOfURL: path)!)!
    return (UIImagePNGRepresentation(image)!, image.size)
  }

  override func updateWithDelta(delta: CFTimeInterval) {
    super.updateWithDelta(delta)
  }
}
