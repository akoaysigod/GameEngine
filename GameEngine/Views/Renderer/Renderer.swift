import Foundation
import MetalKit

final class Renderer {
  private let commandQueue: MTLCommandQueue

  private let shapePipeline: ShapePipeline
  private let spritePipeline: SpritePipeline
  private let textPipeline: TextPipeline
  #if os(iOS)
//  private let lightPipeline: LightPipeline
//  private let compositionPipeline: CompositionPipeline
  #endif //tmp
  private let depthState: MTLDepthStencilState

  private let inflightSemaphore: DispatchSemaphore

  private let bufferManager: BufferManager
  private var bufferIndex = 0

  init(device: MTLDevice, bufferManager: BufferManager) {
    //not sure where to set this up or if I even want to do it this way
    Fonts.cache.device = device
    //-----------------------------------------------------------------

    self.bufferManager = bufferManager

    commandQueue = device.makeCommandQueue()!
    commandQueue.label = "main command queue"

    //descriptorQueue = RenderPassQueue(view: view)

    let factory = PipelineFactory(device: device)
    shapePipeline = factory.makeShapePipeline()
    spritePipeline = factory.makeSpritePipeline()
    textPipeline = factory.makeTextPipeline()
    //tmp
    #if os(iOS)
//    lightPipeline = factory.makeLightPipeline()
//    compositionPipeline = factory.makeCompositionPipeline()
    #endif
    depthState = factory.makeDepthStencil()

    inflightSemaphore = DispatchSemaphore(value: BUFFER_SIZE)
  }

  private var captureCount = 0
  func render(nextRenderPass: NextRenderPass,
              view: Mat4,
              shapeNodes: [ShapeNode],
              spriteNodes: [Int: [SpriteNode]],
              textNodes: [TextNode],
              lightNodes: [LightNode]) {
    _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)

    let commandBuffer = commandQueue.makeCommandBuffer()
    commandBuffer?.label = "main command buffer"

    commandBuffer?.addCompletedHandler { _ in
      (self.inflightSemaphore).signal()
    }

    #if os(macOS)
//    if #available(OSX 10.13, *) {
//      let captureManager = MTLCaptureManager.shared()
//      if !captureManager.isCapturing {
//        captureManager.startCapture(commandQueue: commandQueue)
//      }
//    }
    #endif

    if let (renderPassDescriptor, drawable) = nextRenderPass(),
       let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
      encoder.label = "main encoder"

      encoder.setDepthStencilState(depthState)
      encoder.setFrontFacing(.counterClockwise)
      encoder.setCullMode(.back)

      bufferManager.uniformBuffer.update(data: [view], size: MemoryLayout<Mat4>.size, bufferIndex: bufferIndex, offset: MemoryLayout<Mat4>.size)

      if shapeNodes.count > 0 {
        shapePipeline.encode(encoder: encoder,
                             bufferIndex: bufferIndex,
                             vertexBuffer: bufferManager.shapeVertexBuffer,
                             indexBuffer: bufferManager.shapeIndexBuffer,
                             uniformBuffer: bufferManager.uniformBuffer,
                             nodes: shapeNodes)
      }

      for key in spriteNodes.keys {
        guard let spriteNodes = spriteNodes[key],
              let vertexBuffer = bufferManager[key] else { continue }

        spritePipeline.encode(encoder: encoder,
                              bufferIndex: bufferIndex,
                              vertexBuffer: vertexBuffer,
                              indexBuffer: bufferManager.indexBuffer,
                              uniformBuffer: bufferManager.uniformBuffer,
                              nodes: spriteNodes,
                              lights: lightNodes)
      }

      if textNodes.count > 0 {
        //textPipeline.encode(encoder, nodes: textNodes)
      }

      #if os(iOS) //tmp
//      if let lightNode = lightNodes.first {
//        lightPipeline.encode(encoder!, bufferIndex: bufferIndex, uniformBuffer: bufferManager.uniformBuffer, lightNodes: lightNodes)
//        compositionPipeline.encode(encoder!, ambientColor: lightNode.ambientColor)
//      }
      #endif

      encoder.endEncoding()
      //commandQueue.insertDebugCaptureBoundary()

      commandBuffer?.present(drawable)
    }

    bufferIndex = (bufferIndex + 1) % BUFFER_SIZE

    commandBuffer?.commit()

//    if captureCount < 5 {
//      captureCount += 1
//    }
//    else {
//      #if os(macOS)
//        if #available(OSX 10.13, *) {
//          MTLCaptureManager.shared().stopCapture()
//        }
//      #endif
//    }
  }

  deinit {
    (0..<BUFFER_SIZE).forEach { _ in
      inflightSemaphore.signal()
    }
  }
}
