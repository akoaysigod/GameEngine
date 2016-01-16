//
//  GENode.swift
//  MKTest
//
//  Created by Tony Green on 12/23/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import GLKit
import Metal
import QuartzCore

typealias GENodes = [GENode]

protocol Node {
  var name: String? { get set }
  
  var x: Float { get set }
  var y: Float { get set }
  var position: (x: Float, y: Float) { get set }
  
  var rotation: Float { get set }

  var scale: Float { get set }
  var xScale: Float { get set }
  var yScale: Float { get set }

  var anchorPoint: (x: Float, y: Float) { get set }

  var time: CFTimeInterval
  func updateWithDelta(delta: CFTimeInterval)

  var action: GEAction? { get set }
  var hasAction: Bool { get }
  func runAction(action: GEAction)

  func addChild(node: Node)
}

protocol Renderable: Node {
  var device: MTLDevice! { get }

  var texture: MTLTexture? { get set }
  
  var vertices: Vertices! { get }
  var vertexCount: Int { get }

  var camera: GECamera! { get set }

  var size: CGSize { get set }
  var width: Float { get }
  var height: Float { get }

  var modelMatrix: GLKMatrix4 { get }

  var sharedUniformBuffer: MTLBuffer! { get }
  var uniformBufferQueue: MTLBuffer! { get }

  var isVisible: Bool { get set }

  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState?)
}

public class GENode: TreeNode {
  public var name: String?

  var device: MTLDevice!
  var vertices: Vertices!
  var vertexCount: Int = 1
  private var vertexBuffer: MTLBuffer!
  var size = CGSizeZero
  public var width: Float {
    return Float(self.size.width) * self.xScale
  }
  public var height: Float {
    return Float(self.size.height) * self.yScale
  }

  var texture: MTLTexture?

  public var x: Float = 0.0
  public var y: Float = 0.0
  public var position: (x: Float, y: Float) {
    get { return (x, y) }
    set {
      self.x = newValue.0
      self.y = newValue.1
    }
  }
  public var zPosition: Int = 0
  private var z: Float {
    return -1.0 * Float(self.zPosition) / 10000.0
  }

  public var rotation: Float = 0.0
  public var scale: Float {
    get { return self.pScale }
    set {
      self.xScale = newValue
      self.yScale = newValue
      self.pScale = newValue
    }
  }
  private var pScale: Float = 1.0
  public var xScale: Float = 1.0
  public var yScale: Float = 1.0

  public var anchorPoint: CGPoint {
    get { return CGPoint(x: Double(self.pAnchorPoint.x), y: Double(self.pAnchorPoint.y)) }
    set {
      self.pAnchorPoint = (Float(newValue.x), Float(newValue.y))
    }
  }
  private var pAnchorPoint: (x: Float, y: Float) = (0.0, 0.0)

  var modelMatrix: GLKMatrix4 {
    let x = self.x - (self.width * self.pAnchorPoint.x)
    let y = self.y - (self.height * self.pAnchorPoint.y)

    let xRot = 0.0 - (self.width * self.pAnchorPoint.x)
    let yRot = 0.0 - (self.height * self.pAnchorPoint.y)

    let scale = GLKMatrix4MakeScale(self.xScale, self.yScale, 1.0)
    let worldTranslate = GLKMatrix4MakeTranslation(x - xRot, y - yRot, self.z)
    let rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-1 * self.rotation), 0.0, 0.0, 1.0)
    let rotationTranslate = GLKMatrix4MakeTranslation(xRot, yRot, self.z)

    return worldTranslate * rotation * rotationTranslate * scale
  }

  private var sharedUniformBuffer: MTLBuffer!

  public var camera: GECamera!

  private var uniformBufferQueue: BufferQueue!
  
  var tree = DrawTree()
  var isVisible = true
  let uniqueID = NSUUID().UUIDString

  init() {}
  init(vertices: Vertices, size: CGSize) {
    self.vertices = vertices
    self.vertexCount = vertices.count
    self.size = size
  }
  
  func setupBuffers() {
    let vertexData = self.vertices.flatMap { $0.data }
    let vertexDataSize = vertexData.count * sizeofValue(vertexData[0])
    self.vertexBuffer = self.device.newBufferWithBytes(vertexData, length: vertexDataSize, options: [])

    self.uniformBufferQueue = BufferQueue(device: self.device, dataSize: FloatSize * self.modelMatrix.data.count)
  }
  
  func draw(commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder, sampler: MTLSamplerState? = nil) {
    renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
    
    var parentMatrix = GLKMatrix4Identity
    if case let .Node(_, parentNode, _) = self.tree.tree,
      let parent = parentNode
    {
      parentMatrix = parent.modelMatrix
    }
    let testMatrix = parentMatrix * self.modelMatrix
    
    let offset = self.uniformBufferQueue.next(commandBuffer, data: camera.multiplyMatrices(testMatrix).data)
    renderEncoder.setVertexBuffer(self.uniformBufferQueue.buffer, offset: offset, atIndex: 1)
    
    if let texture = self.texture, sampler = sampler {
      renderEncoder.setFragmentTexture(texture, atIndex: 0)
      renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)
    }
    
    renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: self.vertexCount)
  }
  
  var time: CFTimeInterval = 0.0
  func updateWithDelta(delta: CFTimeInterval) {
    self.time += delta

    guard let action = self.action else { return }
    if !action.completed {
      action.run(self, delta: delta)
    }
    else {
      self.action = nil
    }
  }

  private var action: GEAction? = nil
  public var hasAction: Bool {
    return self.action != nil
  }

  func runAction(action: GEAction) {
    self.action = action
  }
  
  func addChild(node: GENode) {
    self.tree.addNode(self, node: node)
  }
}
