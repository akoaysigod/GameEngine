import Foundation
import simd
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

/**
 The `CameraNode` changes the view port of any nodes attached to it. Basically, rendering the positions, scale, etc., based on the `CameraNode`'s location in the scene.
 Essentially, this moves the `Renderable.modelView`s opposite to wherever it is.
 
 By default, every `Node` added to a `Scene` will have a camera property. 
 
 - note: This doesn't exaclty work like other nodes and I'm still trying to figure that out. If I don't, right now and forever?, only adding a `Camera` to a scene makes sense. 
         Adding a camera to anything else is kind of undefined.
 */
public final class CameraNode: Node {
  public override var transform: Mat4 {
    return .identity
  }
  fileprivate(set) var view: Mat4 = .identity
  fileprivate(set) var inverseView: Mat4 = .identity

  public var scale: Float {
    return zoom
  }

  public var zoom: Float = 1.0 {
    didSet {
      updateTransform()
    }
  }

  fileprivate var width: Float
  fileprivate var height: Float

  public override init(size: Size) {
    width = Float(size.width)
    height = Float(size.height)

    super.init(size: size)

    anchorPoint = Point(x: 0.5, y: 0.5)
    updateTransform()
  }

  func updateSize(_ size: Size) {
    width = size.width
    height = size.height
    updateTransform()
  }

  public override func add(node: Node) {
    super.add(node: node)

    node.camera = self
    node.allNodes.forEach { $0.camera = self }
  }

  override func updateTransform() {
    view = Mat4.translate(position.x + (width * anchorPoint.x), position.y + (height * anchorPoint.y)) * Mat4.scale(zoom, zoom)
    inverseView = Mat4.translate(-1 * (position.x), -1 * (position.y)) * Mat4.scale(1, 1)

    //need to think of a better way to update
    //this isn't terrible
    nodes.forEach {
      if $0.isUINode {
        $0.updateTransform()
      }
    }
  }
}
