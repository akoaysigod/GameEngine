import Metal
import simd

final class LightPipeline: RenderPipeline {
  let pipelineState: MTLRenderPipelineState

  private let resolutionBuffer: Buffer

  private struct Programs {
    static let Shader = "LightShaders"
    static let Vertex = "lightVertex"
    static let Fragment = "lightFragment"
  }

  init(device: MTLDevice,
       vertexProgram: String = Programs.Vertex,
       fragmentProgram: String = Programs.Fragment) {
    let pipelineDescriptor = LightPipeline.makePipelineDescriptor(device: device,
                                                                  vertexProgram: vertexProgram,
                                                                  fragmentProgram: fragmentProgram)

    pipelineState = LightPipeline.createPipelineState(device, descriptor: pipelineDescriptor)!

    resolutionBuffer = Buffer(device: device, length: MemoryLayout<Vec2>.stride)
  }
}

extension LightPipeline {
  func encode(encoder: MTLRenderCommandEncoder, bufferIndex: Int, uniformBuffer: Buffer, lightNodes: [LightNode]) {
    guard let light = lightNodes.first else { return }

    resolutionBuffer.update(data: [light.resolution.vec2], size: MemoryLayout<Vec2>.stride, bufferIndex: bufferIndex)

    encoder.pushDebugGroup("light encoder")

    encoder.setRenderPipelineState(pipelineState)

    let verts = lightNodes.flatMap { $0.verts }
    encoder.setVertexBytes(verts, length: MemoryLayout<packed_float4>.stride * 6 * lightNodes.count, index: 0)

//    var pos = Vec2(0.0, 0.0)
//    encoder.setVertexBytes(&pos, length: MemoryLayout<Vec2>.size, at: 1)
    let (uBuffer, uOffset) = uniformBuffer.next(index: bufferIndex)
    encoder.setVertexBuffer(uBuffer, offset: uOffset, index: 1)

    let (rBuffer, rOffset) = resolutionBuffer.next(index: bufferIndex)
    encoder.setFragmentBuffer(rBuffer, offset: rOffset, index: 0)

    var lightData = lightNodes.compactMap { $0.lightData }
    encoder.setFragmentBytes(&lightData, length: MemoryLayout<LightData>.stride * lightNodes.count, index: 1)

    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6 * lightNodes.count)

    encoder.popDebugGroup()
  }
}
