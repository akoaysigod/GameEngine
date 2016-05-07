//
//  RenderNode.swift
//  GameEngine
//
//  Created by Anthony Green on 1/16/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import QuartzCore
import simd
import UIKit

typealias Renderables = [Renderable]

/**
 The `Renderable` protocol is required by an object that wishes to be rendered. Applying this protocol to an object should be sufficient for creating a custom pipeline.

 The following base classes conform to this protocol:
 - ShapeNode
 - SpriteNode
 - TextNode
 
 - discussion: Currently, this doesn't need to be public as there's no way to add a custom `Pipeline` to the `Renderer` at some point I will expose that.
               I'm just not entirely sure how I want to do it yet.
 
 - seealso: `NodeGeometry` and `Tree`
 */
public protocol Renderable: NodeGeometry, Tree {
  /**
   Holds the vertex data for an object. Currently, perhaps forever, the only way to update the vertices of an object after creating
   is by updating their size using the default implementation of updateSize in `NodeGeometry`.

   - note: All the default renderable objects only have 4 vertices in a rectangular shape.
   
   - warning: For the default renderable objects, the size of this is buffer is the exact size required and therefore should not be updated
              after this object has been added to the draw loop. Currently, it's not a big deal I don't think, but that may change at some point.
   
   - seealso: `func updateSize()`
   */
  var vertexBuffer: MTLBuffer { get }

  /**
   Holds the indices for each vertex of an object. 
   
   - note: By default, this buffer holds [0, 1, 2, 2, 3, 0] where 0, 1, 2 is the upper left triangle, 0 being the lower left vertex.
   
   - seealso: `Quad` for an example.
   */
  var indexBuffer: MTLBuffer { get }

  /// A texture to be applied in the fragment shader.
  var texture: Texture? { get set }
  /// A color to be applied during the fragment shader. By default, this is blended with the texture.
  var color: Color { get set }

  /// sometimes it's nice to just be able to set the alpha of something
  var alpha: Float { get set }

  /// whether or not the object should be rendered
  var hidden: Bool { get set }

  /// whether or not the object is visible from the current view point
  var isVisible: Bool { get }

  /**
   This is used in order to properly update a model matrix of an object based on the parent's model matrix. This, in general, should be used as the 
   model matrix for the uniform buffer and not the default model matrix of the `Renderable` object.

   - note: By default, the `parentMatrix` is the direct parent of a `Renderable` object. I think that's sufficient?

   - parameter parentMatrix: The `Renderable`'s parent model matrix.

   - returns: A new model matrix to be used as this `Renderable`'s model matrix.
   */
  func decompose(node: Node) -> Mat4

  /**
   This is used by the various `Pipeline`s to encode the objects to the `MTLCommandBuffer` to be drawn by the GPU.

   - parameter renderEncoder: The command encoder to use for encoding the commands for drawing the `Renderale` to the command buffer.
   - parameter sampler:       The sampler to use to encode how the shader should sample the texture being applied.
   */
  func draw(renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState?)
}

extension Renderable {
  static func setupBuffers(quads: Quads, device: MTLDevice) -> (vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer) {
    let vertexBuffer = device.newBufferWithBytes(quads.vertexData, length: quads.vertexSize, options: [])
    let indexBuffer = device.newBufferWithBytes(quads.indicesData, length: quads.indicesSize, options: [])

    return (vertexBuffer, indexBuffer)
  }

  public func decompose(node: Node) -> Mat4 {
    let parentMatrix = node.parent?.modelMatrix ?? Mat4.identity
//this does not take into consideration if a node is nested in several parents
    let parentRotScale = parentMatrix.mat3
    let selfRotScale = modelMatrix.mat3
    let rotScale = parentRotScale * selfRotScale

    let parentTranslate = parentMatrix.translation
    let selfTranslate = modelMatrix.translation
    var translate = parentTranslate + selfTranslate
    translate.z = self.z
    translate.w = 1.0

    let column1 = Vec4(vec3: rotScale[0])
    let column2 = Vec4(vec3: rotScale[1])
    let column3 = Vec4(vec3: rotScale[2])
    let column4 = translate

    return Mat4([column1, column2, column3, column4])
  }
}

extension NodeGeometry {
  public func updateSize() {
    guard let renderable = self as? Renderable else { return }

    let quad: Quad
    if renderable.texture == nil {
      quad = .rect(size)
    }
    else {
      quad = .spriteRect(size)
    }

    let p = renderable.vertexBuffer.contents()
    memcpy(p, [quad].vertexData, [quad].vertexSize)
  }
}
