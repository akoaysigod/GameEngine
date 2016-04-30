//
//  Easing.swift
//  GameEngine
//
//  Created by Anthony Green on 4/24/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

public enum EaseFunction {
  case Linear
  case EaseIn
  case EaseOut
  case EaseInOut
  case Custom(c1: (x: Double, y: Double), c2: (x: Double, y: Double))

  private static let linear = Easing.linear()
  private static let easeIn = Easing.easeIn()
  private static let easeOut = Easing.easeOut()
  private static let easeInOut = Easing.easeInOut()

  public var function: Easing {
    switch self {
    case .Linear: return EaseFunction.linear
    case .EaseIn: return EaseFunction.easeIn
    case .EaseOut: return EaseFunction.easeOut
    case .EaseInOut: return EaseFunction.easeInOut
    case .Custom(let c1, let c2):
      return Easing(c1: c1, c2: c2)
    }
  }
}

public final class Easing {
  let s1 = (x: 0.0, y: 0.0)
  let s2 = (x: 1.0, y: 1.0)

  let c1: (x: Double, y: Double)
  let c2: (x: Double, y: Double)

  public init(c1: (x: Double, y: Double), c2: (x: Double, y: Double)) {
    self.c1 = c1
    self.c2 = c2
  }

  public func pointAtTime(t: Double) -> Double {
    assert(t >= 0.0 && t <= 1.0, "bezier parameter is out of bounds")

    let oneminust = (1.0 - t)

    let one = oneminust ** 3
    let two = 3 * t * (oneminust ** 2)
    let thr = 3 * (t**2) * oneminust
    let fur = t**3

    return one * s1.x + two * c1.x + thr * c2.x + fur * s2.x
    //let y = one * s1.y + two * c1.y + thr * c2.y + fur * s2.y
    //return (x, y)
  }

  public static func linear() -> Easing {
    return Easing(c1: (0.0, 0.0), c2: (1.0, 1.0))
  }

  public static func easeIn() -> Easing {
    return Easing(c1: (0.42, 0.0), c2: (1.0, 1.0))
  }

  public static func easeOut() -> Easing {
    return Easing(c1: (0.0, 0.0), c2: (0.58, 1.0))
  }

  public static func easeInOut() -> Easing {
    return Easing(c1: (0.42, 0.0), c2: (0.58, 1.0))
  }
}

infix operator ** {}
private func **(lhs: Double, rhs: Int) -> Double {
  return pow(lhs, Double(rhs))
}
