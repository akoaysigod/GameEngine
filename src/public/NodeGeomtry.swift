//
//  NodeGeometry.swift
//  GameEngine
//
//  Created by Anthony Green on 2/28/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import simd

/**
 The `NodeGeometry` protocol is used to give an object enough information to be placed in a scene and possibly rendered. 
 
 - note: Any rendered `Node` must have the camera property be non-nil. I'm still trying to figure out a nicer way to enforce this.
 
 - discussion: Conforming to this protocol will grant access to most of the underlying maths required to render an object properly. 
               Additionally, conforming to Tree will grant access to adding custom nodes to a `Scene` graph. 
               `Renderable` has all the required information to do both of the above, as well as draw a node using a custom `Pipeline`.
 
 - seealso: `Renderable` and `Tree`.
 */
public protocol NodeGeometry: class {
  /// Any object that wishes to be placed in a `Scene` requires a `Camera`.
  var camera: CameraNode? { get set }

  /**
   The size in world coordinates. This should NOT take the `scale` property into considering.
   By default, modifying this property modifies the actual vectors being used by the GPU.
   
   - seealso: `Renderable` where the default implementation of `func updateSize()` is located.
   */
  var size: Size { get set }
  /// The width in world coordinates. This uses the `scale` property by default.
  var width: Float { get }
  /// The height in world coordinates. This uses the `scale` property by default.
  var height: Float { get }

  /// The rectangle containing the node in world coordinates computed using scale but not rotation.
  var frame: Rect { get }

  /// The rectangle containing the node in local coordiates computed using scale but not rotation.
  var boundingRect: Rect { get }

  /// The relative position to which various calculations will be done. This is in unit coordinates in the coordinate system of the model.
  var anchorPoint: Point { get set }

  /// The x position. This is relative to the parent or if the scene is a parent, then world coordinates.
  var x: Float { get set }
  /// The y position. This is relative to the parent or if the scene is a parent, then world coordinates.
  var y: Float { get set }
  /// A convenience var for getting the position variables.
  var position: Point { get set }
  /// This controls the rendering "depth."
  var zPosition: Int { get set }

  /// How much to rotate by.
  var rotation: Float { get set }

  /// How much to scale by. In general, this does not affect the `size` property but will modify the width and height.
  var scale: (x: Float, y: Float) { get set }
  /**
   A convenience function for setting the xScale and yScale uniformly.

   - parameter scale: The scale to set to.
   */
  func setScale(scale: Float)
  /// How much to scale in the x direction.
  var xScale: Float { get set }
  /// How much to scale in the y direction.
  var yScale: Float { get set }

  /**
   This transforms the relevent data about the `Node` into a `Mat4` to be used to compute the final `modelMatrix` of a `Renderable`.
   The default implementation should be sufficient for creating a custom rendering pipeline.
   
   - seealso: `Renderable` and `Uniforms`.
   */
  var transform: Mat4 { get }

  /**
   This function updates the actual geometry size of the vertices. It's not used as scaling is in the model matrix.
   The actual model matrix will apply it's changes to the update vertices.
   It's default implementation is in `Renderable`.
   
   - seealso: `Renderable`
   */
  func updateSize()
}

public extension NodeGeometry {
  public var width: Float {
    return size.width * xScale
  }

  public var height: Float {
    return size.height * yScale
  }

  public var position: Point {
    get { return Point(x: x, y: y) }
    set {
      x = newValue.x
      y = newValue.y
    }
  }

  public var boundingRect: Rect {
    return Rect(x: x, y: y, width: width, height: height)
  }

  var z: Float {
    return -1.0 * Float(zPosition / Int.max)
  }

  public var scale: (x: Float, y: Float) {
    get { return (xScale, yScale) }
    set {
      xScale = newValue.x
      yScale = newValue.y
    }
  }

  func setScale(scale: Float) {
    self.scale = (scale, scale)
  }

  public var transform: Mat4 {
    let x = self.x - (width * anchorPoint.x)
    let y = self.y - (height * anchorPoint.y)

    let xRot = 0.0 - (width * anchorPoint.x)
    let yRot = 0.0 - (height * anchorPoint.y)

    let scale = Mat4.scale(xScale, yScale)
    let worldTranslate = Mat4.translate(x - xRot, y - yRot, z)
    let rotation = Mat4.rotate(-1 * self.rotation)
    let rotationTranslate = Mat4.translate(xRot, yRot, z)

    return worldTranslate * rotation * rotationTranslate * scale
  }
}
