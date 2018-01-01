import Metal
import MetalKit

//make async at some point
public class TextureLoader {
  private let device: MTLDevice
  private let textureLoader: MTKTextureLoader

  private lazy var errorTexture: Texture = {
    let url = Bundle.main.url(forResource: "error", withExtension: "png")!
    let texture = try! textureLoader.newTexture(URL: url, options: nil)
    return Texture(texture: texture)
  }()

  init(device: MTLDevice) {
    self.device = device
    textureLoader = MTKTextureLoader(device: device)
  }

  /**
   This is the old documentation from texture, I still need to resolve some of these and I don't think
   moving it to a new file to hide Metal stuff will make these problems go away

   Creates a new `Texture` object given a name of an image.

   - warning: not sure why but if you pass in an empty string it uses the last value used somehow
   I still need to figure this weirdness out.

   - discussion: This is loading a `UIImage` to create a texture so passing it names from an xcasset will work.
   I'm not sure if there is a better way to do this as `UIImage` get cached and you should be handlin the caching of
   these `Texture` objects manually.
   //^what does this mean? there is no UIImage here?

   - parameter named: The name of the texture to be used.

   - returns: A new instance of `Texture`.
   */
  //there is a way to use a xcassets to load images but for some reason half of them won't load and the error isn't very helpful
  //I'll try again at another point so I'll just leave the contentScale argument here for fun
  public func getTexture(named: String) -> Texture {
    guard let url = Bundle.main.url(forResource: named, withExtension: "png") else {
      DLog("Image \(named) not found in bundle.")
      return errorTexture
    }

    var texture: MTLTexture?
    do {
      texture = try textureLoader.newTexture(URL: url, options: nil)
    }
    catch let error {
      DLog("Error loading image named \(named): \(error.localizedDescription)")
      texture = nil
    }

    if let texture = texture {
      return Texture(texture: texture)
    }
    return errorTexture
  }

  public func makeTextureAtlas(imageNames: [String], createLightMap: Bool = false) throws -> TextureAtlas {
    let images = imageNames.map { getTexture(named: $0) }

    guard let width = images.first?.width,
      let height = images.first?.height, width == height else {
        DLog("Could be an error image.")
        throw AtlasCreation.dimensions
    }

    let (rows, columns) = factor(images.count)

    guard rows * height < 4096 && columns * width < 4096 else {
      throw AtlasCreation.tooLarge("\(rows * height) by \(columns * width) is probably to large to load into the gpu.")
    }

    let tex = newTexture(width: columns * width, height: rows * height)

    var x = 0
    var y = 0
    var data  = [String: Rect]()
    zip(images, imageNames).forEach { (image, name) in
      let r = MTLRegionMake2D(x, y, width, height)

      let bytesPerRow = width * 4 //magic number sort of I'm assuming the format is 4 bytes per pixel
      var buffer = [UInt8](repeating: 0, count: width * height * 4)
      let lr = MTLRegionMake2D(0, 0, image.width, image.height)
      image.texture.getBytes(&buffer, bytesPerRow: bytesPerRow, from: lr, mipmapLevel: 0)

      tex.replace(region: r, mipmapLevel: 0, withBytes: buffer, bytesPerRow: bytesPerRow)

      data[name] = Rect(x: x, y: y, width: width, height: height)

      x += width
      if x >= columns * width {
        x = 0
        y += height
      }
    }

    let texture = Texture(texture: tex)
    let lightMapTexture = createLightMap ? makeLightMap(texture: texture) : nil
    return TextureAtlas(data: data, texture: texture, lightMapTexture: lightMapTexture, textureNames: imageNames)
  }
}

extension TextureLoader {
  private func factor(_ i: Int) -> (rows: Int, columns: Int) {
    let stop = Int(Float(i) / 2.0)
    var d = 2

    var div = [(Int, Int)]()
    while d < stop {
      if i % d == 0 {
        div += [(d, i / d)]
      }
      d += 1
    }

    if div.count > 1 {
      let mins = div.map { max($0.0, $0.1) - min($0.0, $0.1) }
      let z = zip(mins, Array(0..<div.count)).sorted(by: <)
      return div[z[0].1]
    }
    else if div.count == 1 {
      return (div[0].0, div[0].1)
    }
    return factor(i + 1)
  }

  private func makeLightMap(texture: Texture) -> Texture? {
    let renderer = ComputeRenderer(device: device, srcTexture: texture)
    return renderer.generateTexture()
  }

  private func newTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat = .bgra8Unorm) -> MTLTexture {
    let descriptor = MTLTextureDescriptor()
    descriptor.width = width
    descriptor.height = height
    descriptor.pixelFormat = pixelFormat
    return device.makeTexture(descriptor: descriptor)!
  }
}
