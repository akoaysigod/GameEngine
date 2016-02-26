//
//  GEPipeline.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import MetalKit

//TODO: rethink this

protocol Pipeline {
  var pipelineState: MTLRenderPipelineState! { get }
  init?(device: MTLDevice, vertexProgram: String, fragmentProgram: String)
  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes)
}

private func getPrograms(device: MTLDevice, vertexProgram: String, fragmentProgram: String) -> (vertexProgram: MTLFunction, fragmentProgram: MTLFunction) {
  let defaultLibrary = device.newDefaultLibrary()!
  let vertexProgram = defaultLibrary.newFunctionWithName(vertexProgram)!
  let fragmentProgram = defaultLibrary.newFunctionWithName(fragmentProgram)!
  return (vertexProgram, fragmentProgram)
}

private func getPipelineStateDescriptor(device: MTLDevice, vertexProgram: String, fragmentProgram: String) -> MTLRenderPipelineDescriptor {
  let (vertexProgram, fragmentProgram) = getPrograms(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

  let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
  pipelineStateDescriptor.vertexFunction = vertexProgram
  pipelineStateDescriptor.fragmentFunction = fragmentProgram
  pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
  pipelineStateDescriptor.depthAttachmentPixelFormat = .Depth32Float
  
  return pipelineStateDescriptor
}

private func createRenderEncoder(commandBuffer: MTLCommandBuffer, label: String, renderPassDescriptor: MTLRenderPassDescriptor, pipelineState: MTLRenderPipelineState) -> MTLRenderCommandEncoder {
  let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
  renderEncoder.label = label
  renderEncoder.setRenderPipelineState(pipelineState)
  renderEncoder.setDepthStencilState(TempStencilTest.stencilState)
  
  return renderEncoder
}

//tmp too lazy to refactor everything again just to test if this is what I need
//TODO: stop being lazy this actually works!
final class TempStencilTest {
  let x = 1
  static var stencilState: MTLDepthStencilState!
  
  init(device: MTLDevice) {
    let depthStencilDescriptor = MTLDepthStencilDescriptor()
    depthStencilDescriptor.depthCompareFunction = .GreaterEqual
    depthStencilDescriptor.depthWriteEnabled = true
    
    TempStencilTest.stencilState = device.newDepthStencilStateWithDescriptor(depthStencilDescriptor)
  }
}

final class PipelineFactory {
  let device: MTLDevice

  init(device: MTLDevice) {
    self.device = device
  }

  //TODO: look up below
  //not sure what happens if there is an error I haven't seen one
  func provideColorPipeline(vertexProgram: String, fragmentProgram: String) -> ColorPipeline {
    return ColorPipeline(device: device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
  }

  func provideSpritePipeline(vertexProgram: String, fragmentProgram: String) -> SpritePipeline {
    return SpritePipeline(device: device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
  }

  func provideTextPipeline(vertexProgram: String, fragmentProgram: String) -> TextPipeline {
    return TextPipeline(device: device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
  }
}

final class ColorPipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!

  init?(device: MTLDevice, vertexProgram: String, fragmentProgram: String) {
    let pipelineStateDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
    }
    catch let error {
      print("OH NO! Failed to create pipeline state, error \(error)")
      return nil
    }
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: "color encoder", renderPassDescriptor: renderPassDescriptor, pipelineState: self.pipelineState)

    nodes.flatMap { (node) -> [GERenderNode] in
      if let renderNode = node as? GERenderNode {
        return [renderNode]
      }
      return []
    }.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder)
    }

    renderEncoder.endEncoding()
  }
}

final class SpritePipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  var sampler: MTLSamplerState

  init?(device: MTLDevice, vertexProgram: String, fragmentProgram: String) {
    let pipelineDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    //pipelineStateDescriptor.sampleCount = view.sampleCount
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Nearest
    samplerDescriptor.sAddressMode = .ClampToEdge
    samplerDescriptor.tAddressMode = .ClampToEdge
    samplerDescriptor.normalizedCoordinates = true
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
    }
    catch let error {
      print("OH NO! Failed to create pipeline state, error \(error)")
      return nil
    }
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: "sprite encoder", renderPassDescriptor: renderPassDescriptor, pipelineState: self.pipelineState)
    
    nodes.flatMap { (node) -> [GERenderNode] in
      if let renderNode = node as? GERenderNode {
        return [renderNode]
      }
      return []
    }.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder, sampler: self.sampler)
    }

    renderEncoder.endEncoding()
  }
}

final class TextPipeline: Pipeline {
  var pipelineState: MTLRenderPipelineState!
  var sampler: MTLSamplerState

  init?(device: MTLDevice, vertexProgram: String, fragmentProgram: String) {
    let pipelineDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Linear
    samplerDescriptor.sAddressMode = .ClampToZero
    samplerDescriptor.tAddressMode = .ClampToZero
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    //TODO: add index buffers to everything!
    let x = 1
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .Float4
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    //texture stuff
    vertexDescriptor.attributes[1].format = .Float2
    vertexDescriptor.attributes[1].offset = sizeof(vector_float4)
    vertexDescriptor.attributes[1].bufferIndex = 0
    vertexDescriptor.layouts[0].stepFunction = .PerVertex
    vertexDescriptor.layouts[0].stride = sizeof(Vertex)

    //pipelineDescriptor.vertexDescriptor = vertexDescriptor

    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
    }
    catch let error {
      fatalError("\(error) text pipeline creation")
      return nil
    }
  }

  func encode(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable, commandBuffer: MTLCommandBuffer, nodes: GENodes) {
    let renderEncoder = createRenderEncoder(commandBuffer, label: "text encoder", renderPassDescriptor: renderPassDescriptor, pipelineState: pipelineState)

    nodes.flatMap { (node) -> [GERenderNode] in
      if let renderNode = node as? GERenderNode {
        return [renderNode]
      }
      return []
    }.forEach {
      $0.draw(commandBuffer, renderEncoder: renderEncoder, sampler: self.sampler)
    }

    renderEncoder.endEncoding()
  }
}
