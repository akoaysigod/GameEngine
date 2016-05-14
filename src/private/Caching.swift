//
//  Caching.swift
//  GameEngine
//
//  Created by Anthony Green on 5/14/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

protocol ModelCaching {
  var shouldUpdate: Bool { get }
  var cachedModelMatrix: Mat4 { set get }
}

extension ModelCaching where Self: Updateable {
  var shouldUpdate: Bool {
    return hasAction
  }
}
