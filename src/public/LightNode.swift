//
//  LightNode.swift
//  GameEngine
//
//  Created by Anthony Green on 7/3/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd
import UIKit

public final class LightNode: Node {
  var lightData: LightData {
    return LightData(position: Vec2(relativePosition.x, relativePosition.y), color: color.vec4)
  }

  public var color: Color
  public var alpha: Float {
    get { return color.alpha }
    set {
      color = Color(color.red, color.green, color.blue, newValue)
    }
  }
  var ambientColor: Color {
    return scene?.ambientLightColor ?? .white
  }
  public var hidden: Bool = false
  private(set) public var isVisible = true
  public var radius: Float = 1.0
  private var relativePosition: Point = Point(x: 0, y: 0)

  var resolution: Size {
    //this needs to be in points for some reason I think
    let resolution = UIScreen.mainScreen().bounds.size
    return Size(width: resolution.w, height: resolution.h)
  }

  init(position: Point, color: Color, radius: Float) {
    self.color = color
    self.radius = radius

    super.init()

    self.position = position
  }

  public override func update(delta: CFTimeInterval) {
    //this does not take into account the radius of the light at the moment
    guard let scene = scene,
          let camera = camera else { return }

    let screenPos = scene.convertPointFromScene(position)

    relativePosition = Point(x: screenPos.x / (resolution.width / camera.scale), y: screenPos.y / (resolution.height / camera.scale))

    isVisible = screenPos.x < resolution.width && screenPos.x > 0.0 &&
                screenPos.y < resolution.height && screenPos.y > 0.0

//    guard screenPos.x < resolution.width && screenPos.x > 0.0 &&
//          screenPos.y < resolution.height && screenPos.y > 0.0 else {
//      isVisible = false
//      return
//    }
//
//    isVisible = true
  }
}
