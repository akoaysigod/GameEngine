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

  private let colorPipeline: ColorPipeline
  private let spritePipeline: SpritePipeline
  private let textPipeline: TextPipeline
  private let depthState: MTLDepthStencilState

  private let MaxFrameLag = 3
  private let inflightSemaphore: dispatch_semaphore_t

  init(device: MTLDevice) {
    //not sure where to set this up or if I even want to do it this way
    Fonts.cache.device = device
    //-----------------------------------------------------------------

    commandQueue = device.newCommandQueue()
    commandQueue.label = "main command queue"

    //descriptorQueue = RenderPassQueue(view: view)
    
    let factory = PipelineFactory(device: device)
    colorPipeline = factory.provideColorPipeline()
    spritePipeline = factory.provideSpritePipeline()
    textPipeline = factory.provideTextPipeline()
    depthState = factory.createDepthStencil()

    inflightSemaphore = dispatch_semaphore_create(MaxFrameLag)
  }

  func render(nextRenderPass: NextRenderPass, renderables: Renderables) {
    dispatch_semaphore_wait(inflightSemaphore, DISPATCH_TIME_FOREVER)

    let commandBuffer = commandQueue.commandBuffer()
    commandBuffer.label = "Frame command buffer"

    if let (renderPassDescriptor, drawable) = nextRenderPass() {
      let encoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
      encoder.setDepthStencilState(depthState)

      if let colorNodes: [ShapeNode] = colorPipeline.filterRenderables(renderables) {
        colorPipeline.encode(encoder, nodes: colorNodes)
      }
      
      if let spriteNodes: [SpriteNode] = spritePipeline.filterRenderables(renderables) {
        spritePipeline.encode(encoder, nodes: spriteNodes)
      }

      if let textNodes: [TextNode] = textPipeline.filterRenderables(renderables) {
        textPipeline.encode(encoder, nodes: textNodes)
      }

      encoder.endEncoding()

      commandBuffer.addCompletedHandler { _ in
        dispatch_semaphore_signal(self.inflightSemaphore)
      }

      commandBuffer.presentDrawable(drawable)
    }

    commandBuffer.commit()
  }

  deinit {
    (0...MaxFrameLag).forEach { _ in
      dispatch_semaphore_signal(inflightSemaphore)
    }
  }
}
