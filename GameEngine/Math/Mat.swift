import simd

public protocol Mat {
  associatedtype A

  /// Create a new matrix with 1.0s on the main diagonal.
  static var identity: A { get }
}

//hmm probably a nicer way to do this
extension Mat2: Mat {
  public static var identity: Mat2 {
    return Mat2(1.0)
  }
}

extension Mat3: Mat {
  public static var identity: Mat3 {
    return Mat3(1.0)
  }
}

extension Mat4: Mat {
  public static var identity: Mat4 {
    return Mat4(1.0)
  }
}
