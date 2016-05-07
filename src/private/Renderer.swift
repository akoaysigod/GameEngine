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

  private let descriptorQueue: RenderPassQueue

  private var colorPipeline: ColorPipeline!
  private var spritePipeline: SpritePipeline!
  private var textPipeline: TextPipeline!

  private let MaxFrameLag = 3
  private let inflightSemaphore: dispatch_semaphore_t

  init(view: GameView) {
    let device = view.device

    //not sure where to set this up or if I even want to do it this way
    Fonts.cache.device = device
    //-----------------------------------------------------------------

    self.commandQueue = device.newCommandQueue()
    self.commandQueue.label = "main command queue"

    self.descriptorQueue = RenderPassQueue(view: view)
    
    let factory = PipelineFactory(device: device)
    colorPipeline = factory.provideColorPipeline()
    spritePipeline = factory.provideSpritePipeline()
    textPipeline = factory.provideTextPipeline()

    inflightSemaphore = dispatch_semaphore_create(MaxFrameLag)

    //tmp
    let depthStateDescriptor = MTLDepthStencilDescriptor()
    depthStateDescriptor.depthCompareFunction = .GreaterEqual
    depthStateDescriptor.depthWriteEnabled = true
    depthState = device.newDepthStencilStateWithDescriptor(depthStateDescriptor)
  }
  let depthState: MTLDepthStencilState

  func render(nodes: Renderables) {
    dispatch_semaphore_wait(inflightSemaphore, DISPATCH_TIME_FOREVER)

    let commandBuffer = commandQueue.commandBuffer()
    commandBuffer.label = "Frame command buffer"

    if let (renderPassDescriptor, drawable) = descriptorQueue.next() {
      let encoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
      encoder.setDepthStencilState(depthState)

      if let colorNodes: [ShapeNode] = colorPipeline.filterRenderables(nodes) {
        //colorPipeline.encode(renderPassDescriptor, commandBuffer: commandBuffer, nodes: colorNodes)
        colorPipeline.encode(encoder, commandBuffer: commandBuffer, nodes: colorNodes)
      }
      
      //renderPassDescriptor = descriptorQueue.next()

      if let spriteNodes: [SpriteNode] = spritePipeline.filterRenderables(nodes) {
        //spritePipeline.encode(renderPassDescriptor, commandBuffer: commandBuffer, nodes: spriteNodes)
        spritePipeline.encode(encoder, commandBuffer: commandBuffer, nodes: spriteNodes)
      }
      
      //renderPassDescriptor = descriptorQueue.next()

      if let textNodes: [TextNode] = textPipeline.filterRenderables(nodes) {
        //textPipeline.encode(renderPassDescriptor, commandBuffer: commandBuffer, nodes: textNodes)
        textPipeline.encode(encoder, commandBuffer: commandBuffer, nodes: textNodes)
      }

      encoder.endEncoding()

      commandBuffer.addCompletedHandler { [unowned self] (_) -> Void in
        dispatch_semaphore_signal(self.inflightSemaphore)
      }
      
      commandBuffer.presentDrawable(drawable)
    }

    commandBuffer.commit()
  }
}
