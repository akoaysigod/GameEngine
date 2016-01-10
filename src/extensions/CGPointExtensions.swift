//
//  CGPointExtensions.swift
//  MKTest
//
//  Created by Tony Green on 1/2/16.
//  Copyright © 2016 Tony Green. All rights reserved.
//

import GLKit

extension CGPoint {
  var float: (x: Float, y: Float) {
    return (Float(self.x), Float(self.y))
  }
}
