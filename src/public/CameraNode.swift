//
//  Camera.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import simd
import UIKit

/**
 The `CameraNode` changes the view port of any nodes attached to it. Basically, rendering the positions, scale, etc., based on the `CameraNode`'s location in the scene.
 Essentially, this moves the `Renderable.modelView`s opposite to wherever it is.
 
 By default, every `Node` added to a `Scene` will have a camera property. 
 
 - note: This doesn't exaclty work like other nodes and I'm still trying to figure that out. If I don't, right now and forever?, only adding a `Camera` to a scene makes sense. 
         Adding a camera to anything else is kind of undefined.
 */
final class CameraNode: Node {
  //maybe move this back to being a uniform and batch based on which camera the node is using
  override var transform: Mat4 {
    return view
  }
  private(set) var view: Mat4 = .identity

  var scale: Float {
    return zoom
  }

  var zoom: Float = 1.0 {
    didSet {
      updateTransform()
    }
  }

  private let width: Float
  private let height: Float

  override init(size: Size) {
    width = Float(size.width)
    height = Float(size.height)

    super.init(size: size)

    anchorPoint = Point(x: 0.5, y: 0.5)
    updateTransform()
  }

  override func addNode(node: Node) {
    super.addNode(node)

    node.camera = self
    node.allNodes.forEach { $0.camera = self }
  }

  override func updateTransform() {
    view = Mat4.translate(x + (width * anchorPoint.x), y + (height * anchorPoint.y)) * Mat4.scale(zoom, zoom)
    allNodes.forEach { $0.updateTransform() }
  }
}
