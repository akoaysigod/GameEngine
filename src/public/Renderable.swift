//
//  GERenderNode.swift
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

protocol Renderable: GENodeGeometry, GETree {
  var vertexBuffer: MTLBuffer { get }
  var indexBuffer: MTLBuffer { get }
  var uniformBufferQueue: BufferQueue { get }

  var texture: GETexture? { get set }
  var color: UIColor { get set }

  static func setupBuffers(quads: Quads, device: MTLDevice) -> (vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer)
  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState?)
}

extension Renderable {
  static func setupBuffers(quads: Quads, device: MTLDevice) -> (vertexBuffer: MTLBuffer, indexBuffer: MTLBuffer) {
    let vertexBuffer = device.newBufferWithBytes(quads.vertexData, length: quads.vertexSize, options: [])
    let indexBuffer = device.newBufferWithBytes(quads.indicesData, length: quads.indicesSize, options: [])

    return (vertexBuffer, indexBuffer)
  }

  private func decompose(matrix: Mat4) -> Mat4 {
    let parentRotScale = matrix.mat3
    let selfRotScale = modelMatrix.mat3
    let rotScale = parentRotScale * selfRotScale

    let parentTranslate = matrix.translation
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

  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState? = nil) {
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)

    let parentMatrix = parent?.modelMatrix ?? Mat4.identity

    let uniformMatrix = camera.multiplyMatrices(decompose(parentMatrix))
    let uniformData = Uniforms(mvp: uniformMatrix, color: color)

    let offset = uniformBufferQueue.next(commandBuffer, uniforms: uniformData)
    renderEncoder.setVertexBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    renderEncoder.setFragmentBuffer(uniformBufferQueue.buffer, offset: offset, atIndex: 0)

    if let texture = texture?.texture, sampler = sampler {
      renderEncoder.setFragmentTexture(texture, atIndex: 0)
      renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)
    }

    renderEncoder.drawIndexedPrimitives(.Triangle, indexCount: indexBuffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0)
  }
}

extension GENodeGeometry {
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
