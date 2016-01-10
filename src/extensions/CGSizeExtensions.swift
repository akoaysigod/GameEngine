//
//  CGRectExtensions.swift
//  MKTest
//
//  Created by Tony Green on 1/2/16.
//  Copyright © 2016 Tony Green. All rights reserved.
//

import GLKit

extension CGSize {
  init(width: Float, height: Float) {
    self.init(width: Double(width), height: Double(height))
  }
}
