//
//  CGPointExtensions.swift
//  MKTest
//
//  Created by Anthony Green on 1/2/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import UIKit

extension CGPoint {
  var float: (x: Float, y: Float) {
    return (Float(self.x), Float(self.y))
  }
  
  init(x: Float, y: Float) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
  }
}

extension CGSize {
  var w: Float {
    return Float(width)
  }

  var h: Float {
    return Float(height)
  }

  init(width: Float, height: Float) {
    self.init(width: Double(width), height: Double(height))
  }
}
