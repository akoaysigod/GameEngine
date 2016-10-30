//
//  Device.swift
//  GameEngine
//
//  Created by Anthony Green on 3/6/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Metal
import MetalKit

final class Device {
  static let shared = Device()

  let device: MTLDevice
  let textureLoader: MTKTextureLoader

  init() {
    //hmmm maybe I can just call this wherever I need a MTLDevice?
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("This device probably doesn't support Metal or I don't know why this failed")
    }
    self.device = device
    self.textureLoader = MTKTextureLoader(device: device)
  }
}
