import simd
#if os(iOS)
import UIKit
#else
import Cocoa
#endif

public final class LightNode: Node {
  var lightData: LightData {
    return LightData(position: Vec2(relativePosition.x, relativePosition.y), color: color.vec4, radius: radius)
  }

  var verts: [packed_float4] {
    let ll = PVec4(position.x - radius, position.y - radius, 0.0, 1.0)
    let lr = PVec4(position.x + radius, position.y - radius, 0.0, 1.0)
    let ul = PVec4(position.x - radius, position.y + radius, 0.0, 1.0)
    let ur = PVec4(position.x + radius, position.y + radius, 0.0, 1.0)
    return [ll, lr, ul, ul, lr, ur]

//    return [ 
//      packed_float4(0.0, 0.0, 0.0, 1.0),
//      packed_float4(radius, 0.0, 0.0, 1.0),
//      packed_float4(0.0, radius, 0.0, 1.0),
//
//      packed_float4(radius, 0.0, 0.0, 1.0),
//      packed_float4(radius, radius, 0.0, 1.0),
//      packed_float4(0.0, radius, 0.0, 1.0)
//    ]
  }

  public var color: Color
  public var alpha: Float {
    get { return color.alpha }
    set {
      color = Color(color.red, color.green, color.blue, newValue)
    }
  }
  var ambientColor: Color {
    return scene?.ambientLightColor ?? .white
  }
  public var hidden: Bool = false
  fileprivate(set) public var isVisible = true
  public var radius: Float = 0.0
  fileprivate var relativePosition: Point = Point(x: 0, y: 0)

  var resolution: Size {
    guard let camera = camera else { return .zero }

    //this needs to be in points for some reason I think
    //NO IT DOESNT OMG I don't know when this happened
    //using native screen size doesn't work
    let resolution = Screen.main.nativeBounds.size
    return Size(width: resolution.w * camera.zoom, height: resolution.h * camera.zoom)
  }

  public init(position: Point, color: Color, radius: Float) {
    self.color = color
    self.radius = radius

    super.init()

    self.position = position
  }

  public override func update(delta: CFTimeInterval) {
    //this does not take into account the radius of the light at the moment
    guard let scene = scene,
          let camera = camera else { return }

    let screenPos = scene.convertPointFromScene(position)

    relativePosition = Point(x: screenPos.x / (resolution.width / camera.scale), y: screenPos.y / (resolution.height / camera.scale))

    isVisible = screenPos.x < resolution.width && screenPos.x > 0.0 &&
                screenPos.y < resolution.height && screenPos.y > 0.0

//    guard screenPos.x < resolution.width && screenPos.x > 0.0 &&
//          screenPos.y < resolution.height && screenPos.y > 0.0 else {
//      isVisible = false
//      return
//    }
//
//    isVisible = true
  }
}
