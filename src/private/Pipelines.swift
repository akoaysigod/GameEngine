//
//  GEPipeline.swift
//  MKTest
//
//  Created by Tony Green on 12/30/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import MetalKit



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
final class TempStencilTest {
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
    return ColorPipeline(device: self.device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
  }

  func provideSpritePipeline(vertexProgram: String, fragmentProgram: String) -> SpritePipeline {
    return SpritePipeline(device: self.device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)!
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
    let pipelineStateDescriptor = getPipelineStateDescriptor(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)
    //pipelineStateDescriptor.sampleCount = view.sampleCount

    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .Nearest
    samplerDescriptor.magFilter = .Nearest
    samplerDescriptor.sAddressMode = .ClampToEdge
    samplerDescriptor.tAddressMode = .ClampToEdge
    samplerDescriptor.normalizedCoordinates = true
    self.sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)

    do {
      self.pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
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
