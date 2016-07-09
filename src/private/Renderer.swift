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
  private let commandQueue: MTLCommandQueue

  private let shapePipeline: ShapePipeline
  private let spritePipeline: SpritePipeline
  private let textPipeline: TextPipeline
  private let compositionPipeline: CompositionPipeline
  private let depthState: MTLDepthStencilState

  private let inflightSemaphore: dispatch_semaphore_t

  private let bufferManager: BufferManager
  private var bufferIndex = 0

  init(device: MTLDevice, bufferManager: BufferManager) {
    //not sure where to set this up or if I even want to do it this way
    Fonts.cache.device = device
    //-----------------------------------------------------------------

    self.bufferManager = bufferManager

    commandQueue = device.newCommandQueue()
    commandQueue.label = "main command queue"

    //descriptorQueue = RenderPassQueue(view: view)

    let factory = PipelineFactory(device: device)
    shapePipeline = factory.constructShapePipeline()
    spritePipeline = factory.constructSpritePipeline()
    textPipeline = factory.constructTextPipeline()
    compositionPipeline = factory.constructCompositionPipeline()
    depthState = factory.constructDepthStencil()

    inflightSemaphore = dispatch_semaphore_create(BUFFER_SIZE)
  }

  func render(nextRenderPass: NextRenderPass, view: Mat4, shapeNodes: [ShapeNode], spriteNodes: [Int: [SpriteNode]], textNodes: [TextNode], lightNodes: [LightNode]) {
    dispatch_semaphore_wait(inflightSemaphore, DISPATCH_TIME_FOREVER)

    let commandBuffer = commandQueue.commandBuffer()
    commandBuffer.label = "main command buffer"

    commandBuffer.addCompletedHandler { _ in
      dispatch_semaphore_signal(self.inflightSemaphore)
    }

    if let (renderPassDescriptor, drawable) = nextRenderPass() {
      let encoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
      encoder.label = "main encoder"

      encoder.setDepthStencilState(depthState)
      encoder.setFrontFacingWinding(.CounterClockwise)
      encoder.setCullMode(.Back)

      bufferManager.uniformBuffer.update([view], size: sizeof(Mat4), bufferIndex: bufferIndex, offset: sizeof(Mat4))

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

      compositionPipeline.encode(encoder)

      encoder.endEncoding()

      commandBuffer.presentDrawable(drawable)
    }

    bufferIndex = (bufferIndex + 1) % BUFFER_SIZE

    commandBuffer.commit()
  }

  deinit {
    (0..<BUFFER_SIZE).forEach { _ in
      dispatch_semaphore_signal(inflightSemaphore)
    }
  }
}
