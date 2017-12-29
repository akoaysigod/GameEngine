//
//  Mat4.swift
//  GameEngine
//
//  Created by Anthony Green on 4/10/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

/*
  I could probably drop the end of a lot of this since I'm mostly dealing with 2D space but 
  this so far seems to be easier so unless I see some reason to I'll probably just keep treating everything as being 3D.
*/

import Foundation
import simd

public typealias Mat4 = float4x4

/**
 This is an extension on simd's float4x4.
 
 This mostly provides methods relevant to the graphics math whether or not it's related to 2D or not I'll probably keep adding stuff here when I remember it or need it.
 
 Most of this has been tested against GLKit which was what I was originally using to do the math.
 */
public extension Mat4 {
  /// return the upper left matrix
  public var mat3: Mat3 {
    let r1 = Vec3(vec4: self[0])
    let r2 = Vec3(vec4: self[1])
    let r3 = Vec3(vec4: self[2])

    return Mat3([r1, r2, r3])
  }

  /// get the the translation component
  public var translation: Vec4 {
    return self[3]
  }

  /**
   Create a scaling matrix.

   - parameter x: Amount to scale x by.
   - parameter y: Amount to scale y by.
   - parameter z: Amount to scale z by.

   - returns: A new `Mat4` representing a scaling.
   */
  public static func scale(_ x: Float, _ y: Float, _ z: Float = 1.0) -> Mat4 {
    var m = Mat4.identity
    m[0].x = x
    m[1].y = y
    m[2].z = z
    return m
  }

  /**
   Create a 2D rotation matrix around the z-axis.

   - parameter degrees: The amount to rotate by in degrees.

   - returns: A new `Mat4` representing a 2D rotation.
   */
  public static func rotate(degrees: Float) -> Mat4 {
    return rotateAround(axis: Vec3(0.0, 0.0, 1.0), degrees: degrees)
  }

  /**
   Create a rotation matrix around a certain axis or vector.

   - parameter axis:    The axis to rotate around.
   - parameter degrees: The angle to rotate by in degrees.

   - returns: A new `Mat4` representing a rotation around an axis.
   */
  public static func rotateAround(axis: Vec3, degrees: Float) -> Mat4 {
    let angle = Math.toRadians(degrees: degrees)

    let c = cos(angle)
    let s = sin(angle)

    var m = Mat4()

    m[0].x = c + axis.x * axis.x * (1 - c)
    m[0].y = (axis.y * axis.x) * (1 - c) + axis.z * s
    m[0].z = (axis.z * axis.x) - axis.y * s

    m[1].x = (axis.x * axis.y) * (1 - c) - axis.z * s
    m[1].y = c + axis.y * axis.y * (1 - c)
    m[1].z = (axis.z * axis.y) + axis.x * s

    m[2].x = (axis.x * axis.z) * (1 - c) + axis.y * s
    m[2].y = (axis.y * axis.z) * (1 - c) - axis.x * s
    m[2].z = c + axis.z * axis.z * (1 - c)

    m[3].w = 1

    return m
  }

  /**
   Creates a translation matrix.
   
   - parameter x: x amount to translate.
   - parameter y: y amount to translate.
   - parameter z: z amount to translate.

   - returns: A new `Mat4` representing a translation.
   */
  public static func translate(_ x: Float, _ y: Float, _ z: Float = 0.0) -> Mat4 {
    var m = Mat4.identity

    m[3].x = x
    m[3].y = y
    m[3].z = z

    return m
  }

  /**
   - note: I honestly forget how this works.

   - parameter m:                 A model matrix?
   - parameter nonUniformScaling: Whether it has been non-uniformly scaled.

   - returns: a `Mat3` matrix representing the normals?
   
   - discussion: I'll figure out what this is for someday. I know I used it for lighting but I forget the math and why this was required.

   */
  public static func normalMatrix(_ m: Mat4, nonUniformScaling: Bool = true) -> Mat3 {
    let upperLeft = m.mat3

    if nonUniformScaling {
      return upperLeft.inverse.transpose
    }
    return upperLeft
  }

  /**
   Create a matrix that transforms from world to eye coordinates.

   - parameter eye:    The coordinate of the eye position.
   - parameter center: The coordinate of the point to look at.
   - parameter up:     The up direction of the camera.

   - returns: A new `Mat4` representing the view.
   */
  public static func lookAt(_ eye: Vec3, center: Vec3, up: Vec3 = Vec3(x: 0.0, y: 1.0, z: 0.0)) -> Mat4 {
    /*
     vec4 n = normalize(eye - at);
     vec4 u = normalize(cross(up,n));
     vec4 v = normalize(cross(n,u));
     vec4 t = vec4(0.0, 0.0, 0.0, 1.0);
     mat4 c = mat4(u, v, n, t);
     return c * Translate( -eye );
     */
    let f = normalize(center - eye)
    var u = normalize(up)
    let s = normalize(cross(f, u))
    u = cross(s, f)

    var m = Mat4()

    m[0].x = s.x
    m[0].y = s.y
    m[0].z = s.z

    m[1].x = u.x
    m[1].y = u.y
    m[1].z = u.z

    m[2].x = -f.x
    m[2].y = -f.y
    m[2].z = -f.z

    m[3].x = -dot(s, eye)
    m[3].y = -dot(u, eye)
    m[3].z = dot(f, eye)
    m[3].w = 1.0
    
    return m
  }

  /**
   Create a perspective projection matrix. 
   
   - note: This is probably correct but I should verify it at some point. :)

   - parameter fovy:   The verticle field of view in radians.
   - parameter aspect: The aspect ratio of the screen/viewing area.
   - parameter near:   The near clipping distance. Should be > 0.
   - parameter far:    The far clipping distance. Should be greater than near and > 0.

   - returns: a `Mat4` matrix to be used for projection.
   */
  public static func perspective(_ fovy: Float, aspect: Float, near: Float, far: Float) -> Mat4 {
    assert(near < far && near > 0 && far > 0, "The perspective matrix doesn't make sense.")

    let top = tan(fovy / 2.0) * near
    let right = top * aspect

    var m = Mat4()

    m[0].x = near / right
    m[1].y = near / top
    m[2].z = -(far + near) / (far - near)
    m[2].w = -1.0
    m[3].z = (-2.0 * far * near) / (far - near)

    return m
  }

  /**
   Create an orthographic projection matrix. I believe these are sane defaults for iOS/Metal. 
   Setting only right and top should be sufficient in most cases.
   
   - note: Near is set to -1.0 and far is set to 1.0 since Metal's NDC z space is only size 1.

   - parameter left:   The left coordinate of the projection volume.
   - parameter right:  The right coordinate of the projection volume. The width/height of the screen.
   - parameter bottom: The bottom coordinate of the projection volume.
   - parameter top:    The top coordinate of the projection volume. The width/height of the screen.
   - parameter near:   The near coordinate of the projection volume.
   - parameter far:    The far coordinate of the projection volume. Must be greater than near.

   - returns: a `Mat4` matrix to be used for projection.
   */
  public static func orthographic(_ left: Float = 0.0, right: Float, bottom: Float = 0.0, top: Float, near: Float = -1.0, far: Float = 1.0) -> Mat4 {
    assert(near < far, "The orthographic projection doesn't make sense.")

    let ral = right + left
    let rsl = right - left 
    let tab = top + bottom 
    let tsb = top - bottom
    let fan = far + near 
    let fsn = far - near

    let xRow = Vec4(x: 2.0 / rsl, y: 0.0, z: 0.0, w: 0.0)
    let yRow = Vec4(x: 0.0, y: 2.0 / tsb, z: 0.0, w: 0.0)
    let zRow = Vec4(x: 0.0, y: 0.0, z: -2.0 / fsn, w: 0.0)
    let wRow = Vec4(x: -ral / rsl, y: -tab / tsb, z: -fan / fsn, w: 1.0)

    return Mat4([xRow, yRow, zRow, wRow])
  }

  /**
   Convenience init for creating a `Mat4` using `Vec3`s.

   - note: Need to verify what this does if not passed 4 columns.

   - parameter columns: The columns in the matrix.

   - returns: a new `Mat4`.
   */
  public init(columns: Vec3 ...) {
    assert(columns.count < 4, "Too many columns")

    let c4 = columns.map { Vec4(vec3: $0) }
    self.init(c4)
  }
}

extension Mat4: CustomStringConvertible {
  public var description: String {
    return "\(self[0])\n\(self[1])\n\(self[2])\n\(self[3])\n"
  }
}
