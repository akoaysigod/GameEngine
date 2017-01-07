//
//  TextureLoader.swift
//  GameEngine
//
//  Created by Anthony Green on 1/3/17.
//  Copyright © 2017 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit

//TODO: add async loading
public final class TextureLoader {
  private let device: MTLDevice
  private let mtkLoader: MTKTextureLoader

  private lazy var errorTexture: MTLTexture = {
    let url = Bundle.main.url(forResource: "error", withExtension: "png")!
    return try! self.mtkLoader.newTexture(withContentsOf: url, options: nil)
  }()

  init(device: MTLDevice) {
    self.device = device
    mtkLoader = MTKTextureLoader(device: device)
  }

  private func makeMetalTexture(named: String, contentScale: CGFloat = 1.0) -> MTLTexture {
    let texture: MTLTexture

    guard let url = Bundle.main.url(forResource: named, withExtension: "png") else {
      fatalError("Image \(named) not found in bundle.") //should probably just assert on a failable init
    }

    do {
      texture = try mtkLoader.newTexture(withContentsOf: url, options: nil)
    }
    catch let error {
      DLog("Error loading image named \(named): \(error.localizedDescription)")
      texture = errorTexture
    }

    return texture
  }

  public func makeTexture(named: String, contentScale: CGFloat = 1.0) -> Texture {
    let texture = makeMetalTexture(named: named, contentScale: contentScale)
    return Texture(texture: texture)
  }

  public func makeTextureAtlas(imageNames: [String], contentScale: CGFloat, createLightMap: Bool = false) throws -> TextureAtlas {
    let metalTextures = imageNames.map { makeMetalTexture(named: $0) }
    let uuid = UUID().uuidString
    let textures = metalTextures.map { Texture(texture: $0, uuid: uuid) }
    
    return try TextureAtlas(device: device, imageNames: imageNames, textures: textures, createLightMap: createLightMap)
  }

  typealias NewTextureFunc = (Int, Int, MTLPixelFormat) -> MTLTexture
  func newTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat = .bgra8Unorm) -> MTLTexture {
    let descriptor = MTLTextureDescriptor()
    descriptor.width = width
    descriptor.height = height
    descriptor.pixelFormat = pixelFormat
    return device.makeTexture(descriptor: descriptor)
  }
}
