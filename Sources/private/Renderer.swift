//
//  GERenderer.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import MetalKit

final class Renderer {
  fileprivate let commandQueue: MTLCommandQueue

  fileprivate let shapePipeline: ShapePipeline
  fileprivate let spritePipeline: SpritePipeline
  fileprivate let textPipeline: TextPipeline
  #if os(iOS)
  fileprivate let lightPipeline: LightPipeline
  fileprivate let compositionPipeline: CompositionPipeline
  #endif //tmp
  fileprivate let depthState: MTLDepthStencilState

  fileprivate let inflightSemaphore: DispatchSemaphore

  fileprivate let bufferManager: BufferManager
  fileprivate var bufferIndex = 0

  init(device: MTLDevice, bufferManager: BufferManager) {
    //not sure where to set this up or if I even want to do it this way
    Fonts.cache.device = device
    //-----------------------------------------------------------------

    self.bufferManager = bufferManager

    commandQueue = device.makeCommandQueue()
    commandQueue.label = "main command queue"

    //descriptorQueue = RenderPassQueue(view: view)

    let factory = PipelineFactory(device: device)
    shapePipeline = factory.constructShapePipeline()
    spritePipeline = factory.constructSpritePipeline()
    textPipeline = factory.constructTextPipeline()
    //tmp
    #if os(iOS)
    lightPipeline = factory.constructLightPipeline()
    compositionPipeline = factory.constructCompositionPipeline()
    #endif
    depthState = factory.constructDepthStencil()

    inflightSemaphore = DispatchSemaphore(value: BUFFER_SIZE)
  }

  func render(nextRenderPass: NextRenderPass,
              view: Mat4,
              shapeNodes: [ShapeNode],
              spriteNodes: [Int: [SpriteNode]],
              textNodes: [TextNode],
              lightNodes: [LightNode]) {
    _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)

    let commandBuffer = commandQueue.makeCommandBuffer()
    commandBuffer.label = "main command buffer"

    commandBuffer.addCompletedHandler { _ in
      (self.inflightSemaphore).signal()
    }

    if let (renderPassDescriptor, drawable) = nextRenderPass() {
      let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
      encoder.label = "main encoder"

      encoder.setDepthStencilState(depthState)
      encoder.setFrontFacing(.counterClockwise)
      encoder.setCullMode(.back)

      bufferManager.uniformBuffer.update([view], size: MemoryLayout<Mat4>.size, bufferIndex: bufferIndex, offset: MemoryLayout<Mat4>.size)

      if shapeNodes.count > 0 {
//        shapePipeline.encode(encoder,
//                             bufferIndex: bufferIndex,
//                             vertexBuffer: bufferManager.shapeVertexBuffer,
//                             indexBuffer: bufferManager.shapeIndexBuffer,
//                             uniformBuffer: bufferManager.uniformBuffer,
//                             nodes: shapeNodes)
      }

      for key in spriteNodes.keys {
        guard let spriteNodes = spriteNodes[key],
              let vertexBuffer = bufferManager[key] else { continue }

        spritePipeline.encode(encoder,
                              bufferIndex: bufferIndex,
                              vertexBuffer: vertexBuffer,
                              indexBuffer: bufferManager.indexBuffer,
                              uniformBuffer: bufferManager.uniformBuffer,
                              nodes: spriteNodes,
                              lights: lightNodes)
      }

      if textNodes.count > 0 {
        //textPipeline.encode(encoder, nodes: textNodes)
      }

      #if os(iOS) //tmp
      if let lightNode = lightNodes.first {
        lightPipeline.encode(encoder, bufferIndex: bufferIndex, uniformBuffer: bufferManager.uniformBuffer, lightNodes: lightNodes)
        compositionPipeline.encode(encoder, ambientColor: lightNode.ambientColor)
      }
      #endif

      encoder.endEncoding()

      commandBuffer.present(drawable)
    }

    bufferIndex = (bufferIndex + 1) % BUFFER_SIZE

    commandBuffer.commit()
  }

  deinit {
    (0..<BUFFER_SIZE).forEach { _ in
      inflightSemaphore.signal()
    }
  }
}
