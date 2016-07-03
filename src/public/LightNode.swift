//
//  LightNode.swift
//  GameEngine
//
//  Created by Anthony Green on 7/3/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import UIKit

public final class LightNode: Node {
  public var color: Color
  public var alpha: Float {
    get { return color.alpha }
    set {
      color = Color(color.red, color.green, color.blue, newValue)
    }
  }
  public var hidden: Bool = false
  public var isVisible: Bool {
    return true
  }
  public var intensity: Float = 1.0

  var relativePosition: Point = Point(x: 0, y: 0)

  private var resolution: Point {
    return relativePosition
  }

  init(position: Point, color: Color, intensity: Float) {
    self.color = color
    self.intensity = intensity

    super.init()

    self.position = position
  }
}
