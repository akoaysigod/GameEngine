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
  var label: String { get }
}

extension Pipeline {
  var label: String {
    return "\(Self.self)"
  }

  static func getLibrary(device: MTLDevice) -> MTLLibrary {
    #if TESTTARGET
    return device.newDefaultLibrary()!
    #else
    return try! device.newLibraryWithFile(NSBundle(forClass: ShapePipeline.self).URLForResource("default", withExtension: "metallib")!.path!)
    #endif
  }

  static func newFunction(library: MTLLibrary, functionName: String) -> MTLFunction {
    guard let function = library.newFunctionWithName(functionName) else {
      fatalError("No function for name: \(functionName)")
    }
    return function
  }
}

protocol RenderPipeline: Pipeline {
  //associatedtype NodeType

  var pipelineState: MTLRenderPipelineState { get }
//  func encode(encoder: MTLRenderCommandEncoder, bufferIndex: Int, vertexBuffer: Buffer, indexBuffer: Buffer, uniformBuffer: Buffer, nodes: [NodeType], lights: [LightNode]?)
}

extension RenderPipeline {
  static func getPrograms(device: MTLDevice, vertexProgram: String, fragmentProgram: String?) -> (vertexProgram: MTLFunction, fragmentProgram: MTLFunction?) {
    let defaultLibrary = Self.getLibrary(device)

    let vProgram = Self.newFunction(defaultLibrary, functionName: vertexProgram)

    let fProgram = { () -> MTLFunction? in
      guard let fragmentProgram = fragmentProgram else { return nil }
      return Self.newFunction(defaultLibrary, functionName: fragmentProgram)
    }()

    return (vProgram, fProgram)
  }

  static func createPipelineDescriptor(device: MTLDevice,
                                       vertexProgram: String,
                                       fragmentProgram: String?) -> MTLRenderPipelineDescriptor {
    let (vertexProgram, fragmentProgram) = getPrograms(device, vertexProgram: vertexProgram, fragmentProgram: fragmentProgram)

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexProgram
    pipelineDescriptor.fragmentFunction = fragmentProgram
    pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
    pipelineDescriptor.colorAttachments[1].pixelFormat = .BGRA8Unorm
    pipelineDescriptor.colorAttachments[2].pixelFormat = .BGRA8Unorm
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
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .Float4
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0

    vertexDescriptor.attributes[1].format = .Float4
    vertexDescriptor.attributes[1].offset = sizeof(packed_float4)
    vertexDescriptor.attributes[1].bufferIndex = 0

    vertexDescriptor.attributes[2].format = .Float2
    vertexDescriptor.attributes[2].offset = sizeof(packed_float4) * 2
    vertexDescriptor.attributes[2].bufferIndex = 0

    vertexDescriptor.layouts[0].stepFunction = .PerVertex
    vertexDescriptor.layouts[0].stride = strideof(Vertex)

    pipelineDescriptor.vertexDescriptor = vertexDescriptor

    pipelineDescriptor.label = "\(Self.self)"

    return pipelineDescriptor
  }

  static func createPipelineState(device: MTLDevice, descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
    do {
      return try device.newRenderPipelineStateWithDescriptor(descriptor)
    }
    catch let error as NSError {
      //this seems to fail only on trying to pass it poorly formatted descriptors
      fatalError("\(Self.self): Failed to create pipeline state, Error:\n" + error.description)
    }
  }
}

final class PipelineFactory {
  private let device: MTLDevice

  init(device: MTLDevice) {
    self.device = device
  }

  func constructDepthStencil() -> MTLDepthStencilState {
    let depthStateDescriptor = MTLDepthStencilDescriptor()
    depthStateDescriptor.depthCompareFunction = .GreaterEqual
    depthStateDescriptor.depthWriteEnabled = true

    return device.newDepthStencilStateWithDescriptor(depthStateDescriptor)
  }

  func constructShapePipeline() -> ShapePipeline {
    return ShapePipeline(device: device)
  }

  func constructSpritePipeline() -> SpritePipeline {
    return SpritePipeline(device: device)
  }

  func constructTextPipeline() -> TextPipeline {
    return TextPipeline(device: device)
  }

  func constructLightPipeline() -> LightPipeline {
    return LightPipeline(device: device)
  }

  func constructCompositionPipeline() -> CompositionPipeline {
    return CompositionPipeline(device: device)
  }
}
