import Metal

// lol srsly wtf? fix these index variables when apple fixes them
// for some reason the compiler doesn't like pointer + something + something 
// parens didn't fix it

final class Buffer { //might change this to a protocol 
  private var buffer: MTLBuffer
  private let length: Int

  init(device: MTLDevice, length: Int, instances: Int = BUFFER_SIZE) {
    self.length = length
    buffer = device.makeBuffer(length: length * instances, options: MTLResourceOptions())!
  }

  func add<T>(data: [T], size: Int, offset: Int = 0) {
    var wtf = size * offset
    memcpy(buffer.contents() + wtf, data, size)
    wtf += length
    memcpy(buffer.contents() + wtf, data, size)
    memcpy(buffer.contents() + length * 2 + (size * offset), data, size) //LOL this is fine though?
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

  func nextBuffer(_ bufferIndex: Int) -> (buffer: MTLBuffer, offset: Int) {
    return (buffer, bufferIndex * length)
  }
}
