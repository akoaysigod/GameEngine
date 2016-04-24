//
//  Easing.swift
//  GameEngine
//
//  Created by Anthony Green on 4/24/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

enum EaseFunction {
  case Linear
}

public final class Easing<T: FloatLiteralConvertible> {
  let s1 = (x: 0.0, y: 0.0)
  let s2 = (x: 1.0, y: 1.0)

  let c1: (x: T, y: T)
  let c2: (x: T, y: T)

  public init(c1: (x: T, y: T), c2: (x: T, y: T)) {
    self.c1 = c1
    self.c2 = c2
  }

  public func pointAtTime(t: T) -> (x: T, y: T) {
    assert(t >= 0 && t <= 1.0, "bezier parameter is out of bounds")

    let oneminust = (1 - t)

    let one = oneminust ** 3
    let two = 3 * t * (oneminust ** 2)
    let thr = 3 * (t**2) * oneminust
    let fur = (t**3)

    let x = one * s1.x + two * c1.x + thr * c2.x + fur * s2.x
    let y = one * s1.y + two * c1.y + thr * c2.y + fur * s2.y

    return (x, y)
  }
}