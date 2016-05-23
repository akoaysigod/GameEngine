//
//  Pipeline.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation
import MetalKit
import simd

protocol Pipeline {
  var pipelineState: MTLRenderPipelineState { get }
  var sampler: MTLSamplerState? { get }
}

extension Pipeline {
  var label: String {
    return "\(Self.self)"
  }

  static func getPrograms(device: MTLDevice, vertexProgram: String, fragmentProgram: String) -> (vertexProgram: MTLFunction, fragmentProgram: MTLFunction) {
    #if TESTTARGET
    let defaultLibrary = device.newDefaultLibrary()!
    #else
    let defaultLibrary = try! device.newLibraryWithFile(NSBundle(forClass: ShapePipeline.self).URLForResource("default", withExtension: "metallib")!.path!)
    #endif

    guard let vProgram = defaultLibrary.newFunctionWithName(vertexProgram) else {
      fatalError("no vertex program for name: \(vertexProgram)")
    }
    guard let fProgram = defaultLibrary.newFunctionWithName(fragmentProgram) else {
      fatalError("no fragment program for name: \(fragmentProgram)")
    }
    return (vProgram, fProgram)
  }

  static func createPipelineDescriptor(device: MTLDevice,
                                               vertexProgram: String,
                                               fragmentProgram: String) -> MTLRenderPipelineDescriptor {
    let (vertexProgram, fragmentProgram) = getPrograms(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexProgram
    pipelineDescriptor.fragmentFunction = fragmentProgram
    pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
    pipelineDescriptor.depthAttachmentPixelFormat = .Depth32Float

    //alpha testing
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add

    //vertex stuff
    let vertexDescriptor = MTLVertexDescriptor();
    vertexDescriptor.attributes[0].format = .Float4
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    vertexDescriptor.attributes[1].format = .Float2
    vertexDescriptor.attributes[1].offset = sizeof(packed_float4)
    vertexDescriptor.attributes[1].bufferIndex = 0
    vertexDescriptor.layouts[0].stride = sizeof(packed_float4) + sizeof(packed_float2)

    pipelineDescriptor.vertexDescriptor = vertexDescriptor
    
    return pipelineDescriptor
  }

  static func createPipelineState(device: MTLDevice, descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
    do {
      return try device.newRenderPipelineStateWithDescriptor(descriptor)
    }
    catch let error {
      //this seems to fail only on trying to pass it poorly formatted descriptors
      fatalError("\(Self.self): Failed to create pipeline state, error \(error)")
    }
  }

  func createRenderEncoder(commandBuffer: MTLCommandBuffer, label: String, renderPassDescriptor: MTLRenderPassDescriptor, pipelineState: MTLRenderPipelineState, depthState: MTLDepthStencilState) -> MTLRenderCommandEncoder {
    let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
    renderEncoder.label = label
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthState)
    
    return renderEncoder
  }
}

final class PipelineFactory {
  private let device: MTLDevice
  private let indexBuffer: Buffer
  private let uniformBuffer: Buffer

  init(device: MTLDevice, indexBuffer: Buffer, uniformBuffer: Buffer) {
    self.device = device

    self.indexBuffer = indexBuffer
    self.uniformBuffer = uniformBuffer
  }

  func constructDepthStencil() -> MTLDepthStencilState {
    let depthStateDescriptor = MTLDepthStencilDescriptor()
    depthStateDescriptor.depthCompareFunction = .GreaterEqual
    depthStateDescriptor.depthWriteEnabled = true
    
    return device.newDepthStencilStateWithDescriptor(depthStateDescriptor)
  }

  func constructShapePipeline() -> ShapePipeline {
    return ShapePipeline(device: device, indexBuffer: indexBuffer, uniformBuffer: uniformBuffer)
  }

  func constructSpritePipeline() -> SpritePipeline {
    return SpritePipeline(device: device, indexBuffer: indexBuffer, uniformBuffer: uniformBuffer)
  }

  func constructTextPipeline() -> TextPipeline {
    return TextPipeline(device: device, indexBuffer: indexBuffer, uniformBuffer: uniformBuffer)
  }
}
