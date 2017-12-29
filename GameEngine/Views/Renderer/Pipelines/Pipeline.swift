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
    return try! device.makeLibrary(filepath: Bundle(for: ShapePipeline.self).url(forResource: "default", withExtension: "metallib")!.path)
    #endif
  }

  static func newFunction(library: MTLLibrary, functionName: String) -> MTLFunction {
    guard let function = library.makeFunction(name: functionName) else {
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
  private static func getPrograms(device: MTLDevice,
                                  vertexProgram: String,
                                  fragmentProgram: String?) -> (vertexProgram: MTLFunction, fragmentProgram: MTLFunction?) {
    let defaultLibrary = Self.getLibrary(device: device)

    let vProgram = Self.newFunction(library: defaultLibrary, functionName: vertexProgram)

    let fProgram = { () -> MTLFunction? in
      guard let fragmentProgram = fragmentProgram else { return nil }
      return Self.newFunction(library: defaultLibrary, functionName: fragmentProgram)
    }()

    return (vProgram, fProgram)
  }

  static func makePipelineDescriptor(device: MTLDevice,
                                     vertexProgram: String,
                                     fragmentProgram: String?) -> MTLRenderPipelineDescriptor {
    let (vertexProgram, fragmentProgram) = getPrograms(device: device,
                                                       vertexProgram: vertexProgram,
                                                       fragmentProgram: fragmentProgram)

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexProgram
    pipelineDescriptor.fragmentFunction = fragmentProgram
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineDescriptor.colorAttachments[1].pixelFormat = .bgra8Unorm
    pipelineDescriptor.colorAttachments[2].pixelFormat = .bgra8Unorm
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

    //alpha testing
    pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

    //vertex stuff
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float4
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0

    vertexDescriptor.attributes[1].format = .float4
    vertexDescriptor.attributes[1].offset = MemoryLayout<packed_float4>.size
    vertexDescriptor.attributes[1].bufferIndex = 0

    vertexDescriptor.attributes[2].format = .float2
    vertexDescriptor.attributes[2].offset = MemoryLayout<packed_float4>.size * 2
    vertexDescriptor.attributes[2].bufferIndex = 0

    vertexDescriptor.layouts[0].stepFunction = .perVertex
    vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

    pipelineDescriptor.vertexDescriptor = vertexDescriptor

    pipelineDescriptor.label = "\(Self.self)"

    return pipelineDescriptor
  }

  static func createPipelineState(_ device: MTLDevice, descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
    do {
      return try device.makeRenderPipelineState(descriptor: descriptor)
    }
    catch let error as NSError {
      //this seems to fail only on trying to pass it poorly formatted descriptors
      fatalError("\(Self.self): Failed to create pipeline state, Error:\n" + error.description)
    }
  }
}

final class PipelineFactory {
  fileprivate let device: MTLDevice

  init(device: MTLDevice) {
    self.device = device
  }

  func makeDepthStencil() -> MTLDepthStencilState {
    let depthStateDescriptor = MTLDepthStencilDescriptor()
    depthStateDescriptor.depthCompareFunction = .greaterEqual
    depthStateDescriptor.isDepthWriteEnabled = true

    return device.makeDepthStencilState(descriptor: depthStateDescriptor)!
  }

  func makeShapePipeline() -> ShapePipeline {
    return ShapePipeline(device: device)
  }

  func makeSpritePipeline() -> SpritePipeline {
    return SpritePipeline(device: device)
  }

  func makeTextPipeline() -> TextPipeline {
    return TextPipeline(device: device)
  }

  func makeLightPipeline() -> LightPipeline {
    return LightPipeline(device: device)
  }

  func makeCompositionPipeline() -> CompositionPipeline {
    return CompositionPipeline(device: device)
  }
}
