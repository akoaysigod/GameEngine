//
//  GLMatrix4Extensions.swift
//  MKTest
//
//  Created by Tony Green on 12/23/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import GLKit

//Vector4
func +(lhs: GLKVector4, rhs: GLKVector4) -> GLKVector4 {
  return GLKVector4Add(lhs, rhs)
}

extension GLKVector4: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "\(x, y, z, w)"
  }
}


//Matrix3
func *(lhs: GLKMatrix3, rhs: GLKMatrix3) -> GLKMatrix3 {
  return GLKMatrix3Multiply(lhs, rhs)
}

extension GLKMatrix3: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "\(m00) \(m01) \(m02)\n" +
           "\(m10) \(m11) \(m12)\n" +
           "\(m20) \(m21) \(m22)"
  }
}

//Matrix4
func *(lhs: GLKMatrix4, rhs: GLKMatrix4) -> GLKMatrix4 {
  return GLKMatrix4Multiply(lhs, rhs)
}

extension GLKMatrix4 {
  var data: [Float] {
    return [
      m00, m01, m02, m03,
      m10, m11, m12, m13,
      m20, m21, m22, m23,
      m30, m31, m32, m33
    ]
  }
}

extension GLKMatrix4: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "\(m00) \(m01) \(m02) \(m30)\n" +
           "\(m10) \(m11) \(m12) \(m31)\n" +
           "\(m20) \(m21) \(m22) \(m32)\n" +
           "\(m03) \(m13) \(m23) \(m33)"
  }
}
