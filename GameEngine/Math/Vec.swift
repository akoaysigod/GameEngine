import simd

public protocol Vec {
  /// The vector as an array.
  var array: [Float] { get }

  /**
   Given a vector return the dot product of the two vectors. 

   - parameter vec: The vector to take the product with.
   
   - returns: The dot product of the two vectors.
   */
  func dot(vec: Vec) -> Float
}

extension Vec {
  public func dot(vec: Vec) -> Float {
    return zip(array, vec.array).map { $0.0 * $0.1 }.reduce(0.0, +)
  }
}

extension Vec2: Vec {
  public var array: [Float] {
    return [x, y]
  }
}

extension Vec3: Vec {
  public var array: [Float] {
    return [x, y, z]
  }
}

extension Vec4: Vec {
  public var array: [Float] {
    return [x, y, z, w]
  }
}
