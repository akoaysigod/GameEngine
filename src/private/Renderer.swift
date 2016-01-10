//
//  GERenderer.swift
//  MKTest
//
//  Created by Tony Green on 12/23/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import MetalKit

final class Renderer {
  struct ShaderPrograms {
    static let ColorVertex = "colorVertex"
    static let ColorFragment = "colorFragment"
    static let SpriteVertex = "spriteVertex"
    static let SpriteFragment = "spriteFragment"
  }

  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue

  private let MaxBuffers = 3
  private var bufferIndex = 0

  private let descriptorQueue: RenderPassQueue

  private var colorPipeline: ColorPipeline!
  private var spritePipeline: SpritePipeline!

  init(view: GEView) {
    self.device = view.device!
    self.commandQueue = self.device.newCommandQueue()
    self.commandQueue.label = "main command queue"


    self.descriptorQueue = RenderPassQueue(view: view)

    self.setupPipelines()
  }

  func setupPipelines() {
    let factory = PipelineFactory(device: self.device)
    self.colorPipeline = factory.provideColorPipeline(ShaderPrograms.ColorVertex, fragmentProgram: ShaderPrograms.ColorFragment)
    self.spritePipeline = factory.provideSpritePipeline(ShaderPrograms.SpriteVertex, fragmentProgram: ShaderPrograms.SpriteFragment)
  }

  func draw(nodes: GENodes) {
    let commandBuffer = self.commandQueue.commandBuffer()
    commandBuffer.label = "Frame command buffer"

    if let drawable = self.descriptorQueue.currentDrawable {
      var renderPassDescriptor = self.descriptorQueue.next()

      //this will work for now :( not sure of a better way to break this stuff up
      let colorNodes = nodes.filter { $0.texture == nil }
      self.colorPipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: colorNodes)

      renderPassDescriptor = self.descriptorQueue.next()
      let spriteNodes = nodes.filter { $0.texture != nil }
      if spriteNodes.count > 0 {
        self.spritePipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: spriteNodes)
      }

      commandBuffer.presentDrawable(drawable)
    }

    self.bufferIndex = (self.bufferIndex + 1) % self.MaxBuffers

    commandBuffer.commit()
  }
}
