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
  struct ShaderPrograms {
    static let ColorVertex = "colorVertex"
    static let ColorFragment = "colorFragment"
    static let SpriteVertex = "spriteVertex"
    static let SpriteFragment = "spriteFragment"
    static let TextVertex = "textVertex"
    static let TextFragment = "textFragment"
  }

  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue

  private let MaxBuffers = 3
  private var bufferIndex = 0

  private let descriptorQueue: RenderPassQueue

  private var colorPipeline: ColorPipeline!
  private var spritePipeline: SpritePipeline!
  private var textPipeline: TextPipeline!

  //TODO: pass a UIColor in here somehow to pass to the RenderPassQueue for background color
  init(view: GEView) {
    self.device = view.device!
    self.commandQueue = self.device.newCommandQueue()
    self.commandQueue.label = "main command queue"

    self.descriptorQueue = RenderPassQueue(view: view)
    
    self.setupPipelines()
  }

  func setupPipelines() {
    let factory = PipelineFactory(device: self.device)
    colorPipeline = factory.provideColorPipeline(ShaderPrograms.ColorVertex, fragmentProgram: ShaderPrograms.ColorFragment)
    spritePipeline = factory.provideSpritePipeline(ShaderPrograms.SpriteVertex, fragmentProgram: ShaderPrograms.SpriteFragment)
    textPipeline = factory.provideTextPipeline(ShaderPrograms.TextVertex, fragmentProgram: ShaderPrograms.TextFragment)
  }

  func draw(nodes: Renderables) {
    let commandBuffer = self.commandQueue.commandBuffer()
    commandBuffer.label = "Frame command buffer"

    if let drawable = self.descriptorQueue.currentDrawable {
      var renderPassDescriptor = self.descriptorQueue.next()

      //this will work for now :( not sure of a better way to break this stuff up
      //holy fuck there was god dammit debugging shaders because of this stupid filter shit
      //refactor this to just pass the whole array to each pipeline they're already filtering nodes out

      if let colorNodes: [GEColorRect] = colorPipeline.filterRenderables(nodes) {
        colorPipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: colorNodes)
      }
      
      renderPassDescriptor = self.descriptorQueue.next()

      if let spriteNodes: [GESprite] = spritePipeline.filterRenderables(nodes) {
        spritePipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: spriteNodes)
      }
      
      renderPassDescriptor = self.descriptorQueue.next()

      if let textNodes: [GETextLabel] = textPipeline.filterRenderables(nodes) {
        textPipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: textNodes)
      }

      commandBuffer.presentDrawable(drawable)
    }

    self.bufferIndex = (self.bufferIndex + 1) % self.MaxBuffers

    commandBuffer.commit()
  }
}
