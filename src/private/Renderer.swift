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

  private let view: MTKView
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue

  private let inflightSemaphore: dispatch_semaphore_t
  private let MaxBuffers = 3
  private var bufferIndex = 0

  private let descriptorQueue: RenderPassQueue

  private var colorPipeline: ColorPipeline!
  private var spritePipeline: SpritePipeline!

  init(device: MTLDevice, view: MTKView) {
    self.device = device
    self.view = view
    self.commandQueue = self.device.newCommandQueue()
    self.commandQueue.label = "main command queue"

    self.inflightSemaphore = dispatch_semaphore_create(self.MaxBuffers)

    self.descriptorQueue = RenderPassQueue(view: view)

    self.setupPipelines()
  }

  func setupPipelines() {
    let factory = PipelineFactory(device: self.device)
    self.colorPipeline = factory.provideColorPipeline(ShaderPrograms.ColorVertex, fragmentProgram: ShaderPrograms.ColorFragment)
    self.spritePipeline = factory.provideSpritePipeline(ShaderPrograms.SpriteVertex, fragmentProgram: ShaderPrograms.SpriteFragment)
  }

  func draw(nodes: GENodes) {
    //this stuff isn't currently doing anything, maybe move to GENode?
    dispatch_semaphore_wait(self.inflightSemaphore, DISPATCH_TIME_FOREVER)

    let commandBuffer = self.commandQueue.commandBuffer()
    commandBuffer.label = "Frame command buffer"
    commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
      if let strongSelf = self {
        dispatch_semaphore_signal(strongSelf.inflightSemaphore)
      }
      return
    }

    if let drawable = self.descriptorQueue.currentDrawable {
      var renderPassDescriptor = self.descriptorQueue.next()

      //this will work for now :( not sure of a better way to break this stuff up
      let colorNodes = nodes.filter { $0.texture == nil }
      self.colorPipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: colorNodes)

      renderPassDescriptor = self.descriptorQueue.next()
      let spriteNodes = nodes.filter { $0.texture != nil }
      self.spritePipeline.encode(renderPassDescriptor, drawable: drawable, commandBuffer: commandBuffer, nodes: spriteNodes)

      commandBuffer.presentDrawable(drawable)
    }

    self.bufferIndex = (self.bufferIndex + 1) % self.MaxBuffers

    commandBuffer.commit()
  }
}
