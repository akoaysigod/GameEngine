//
//  TextureFrame.swift
//  GameEngine
//
//  Created by Anthony Green on 3/27/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

struct TextureFrame {
  let x: Float
  let y: Float
  let sWidth: Float
  let sHeight: Float
  let tWidth: Float
  let tHeight: Float

  init(x: Int, y: Int, sWidth: Int, sHeight: Int, tWidth: Int, tHeight: Int) {
    self.x = Float(x)
    self.y = Float(y)
    self.sWidth = Float(sWidth)
    self.sHeight = Float(sHeight)
    self.tWidth = Float(tWidth)
    self.tHeight = Float(tHeight)
  }
}