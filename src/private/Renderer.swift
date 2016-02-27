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

  init(view: GEView) {
    let device = view.device!

    self.commandQueue = device.newCommandQueue()
    self.commandQueue.label = "main command queue"

    self.descriptorQueue = RenderPassQueue(view: view)
    
    let factory = PipelineFactory(device: device)
    self.colorPipeline = factory.provideColorPipeline()
    self.spritePipeline = factory.provideSpritePipeline()
    self.textPipeline = factory.provideTextPipeline()
  }

  func draw(nodes: Renderables) {
    let commandBuffer = commandQueue.commandBuffer()
    commandBuffer.label = "Frame command buffer"

    if let drawable = descriptorQueue.currentDrawable {
      var renderPassDescriptor = descriptorQueue.next()

      if let colorNodes: [GEColorRect] = colorPipeline.filterRenderables(nodes) {
        colorPipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: colorNodes)
      }
      
      renderPassDescriptor = descriptorQueue.next()

      if let spriteNodes: [GESprite] = spritePipeline.filterRenderables(nodes) {
        spritePipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: spriteNodes)
      }
      
      renderPassDescriptor = descriptorQueue.next()

      if let textNodes: [GETextLabel] = textPipeline.filterRenderables(nodes) {
        textPipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: textNodes)
      }

      commandBuffer.presentDrawable(drawable)
    }

    commandBuffer.commit()
  }
}
