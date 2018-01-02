import Metal

final class Buffer { //might change this to a protocol
  private var buffer: MTLBuffer
  private let length: Int

  init(device: MTLDevice, length: Int, instances: Int = BUFFER_SIZE) {
    self.length = length
    buffer = device.makeBuffer(length: length * instances, options: MTLResourceOptions())!
  }

  func add<T>(data: [T], size: Int, offset: Int = 0) {
    for i in 0..<BUFFER_SIZE {
      let wtf = (length * i) + (size * offset) //This still hasn't been fixed :(
      memcpy(buffer.contents() + wtf, data, size)
    }
  }

  func update<T>(data: [T], size: Int, bufferIndex: Int, offset: Int = 0) {
    #if DEBUG
      if MemoryLayout<T>.size != MemoryLayout<T>.stride {
        DLog("Possibly wrong sized data, \(T.self)")
      }
    #endif
    let wtf = offset + (bufferIndex * length)
    memcpy(buffer.contents() + wtf, data, size)
  }

  func next(index: Int) -> (buffer: MTLBuffer, offset: Int) {
    return (buffer, index * length)
  }
}
