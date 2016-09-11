//
//  TestGameViewController.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Metal
import MetalKit
import UIKit

/**
 The `TestGameViewController` is responsible for mainly the game/rendering loop.

 A basic setup in viewDidLoad() would look something like

 ````
 super.viewDidLoad()

 let view = self.view as! GameView
 scene = Scene(size: view.bounds.size)
 view.presentScene(scene)
 ````
 */
final class TestGameViewController: UIViewController {
  var scene: Scene!

  fileprivate var currentTime = 0.0

  override func loadView() {
    view = GameView(frame: UIScreen.main.bounds)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    //let fontTest = FontAtlas(font: UIFont.systemFontOfSize(15.0))


    let view = self.view as! GameView
    view.clearColor = Color(0.0, 0.5, 0.0, 1.0)
    scene = Scene(size: view.size, tileSize: 64)
    scene.ambientLightColor = Color(0.25, 0.25, 0.25)
    view.presentScene(scene)

    let imageNames = ["Wall", "Floor", "OpenDoor", "StairsDown"]
    //let imageNames = ["AngelBlue", "AngelBrown", "AngelGrey", "AngelGrey2", "AngelOrange", "AngelPurple", "AngelRed", "AngelSilver", "AntBlack"]

    if let environmentAtlas = try? TextureAtlas(imageNames: imageNames, createLightMap: true),
      let wall = environmentAtlas["Wall"],
      let floor = environmentAtlas["Floor"],
      let openDoor = environmentAtlas["OpenDoor"],
      let stairsDown = environmentAtlas["StairsDown"]
      //let stairsUp = environmentAtlas["StairsUp"]
//      let wall = environmentAtlas["AngelBlue"],
//      let floor = environmentAtlas["AngelBrown"],
//      let openDoor = environmentAtlas["AngelGrey"],
//      let stairsDown = environmentAtlas["AngelOrange"],
//      let stairsUp = environmentAtlas["AngelPurple"]
    {
      let _ = [wall, floor, openDoor, stairsDown]

      (-5..<5).forEach { y in
        (-5..<5).forEach { x in
          let sp: SpriteNode
          if y == -5 || y == 4 || x == -5 || x == 4 {
            sp = SpriteNode(texture: wall)
          }
          else {
            sp = SpriteNode(texture: floor)
          }
          sp.position = Point(x: sp.size.width * Float(x), y: sp.size.height * Float(y))
          scene.addNode(sp)
        }
      }

//      let stairs = SpriteNode(texture: stairsDown)
//      stairs.anchorPoint = Point(x: 0.5, y: 0.5)
//      stairs.position = Point(x: 0.0, y: 0.0)
//      stairs.zPosition = 1
//      scene.addNode(stairs)

      let light = LightNode(position: Point(x: 0.0, y: 0.0), color: Color(0.67, 0.16, 0.0), radius: 400.0)
      scene.addNode(light)
//      var nodes = [SpriteNode]()
//      for y in (-10..<10) {
//        for x in (-10..<10) {
//          let t = s[Int(arc4random_uniform(UInt32(s.count)))]
//          let sp = SpriteNode(texture: t)
//          let x = sp.size.width * Float(x)
//          let y = sp.size.height * Float(y)
//          sp.position = Point(x: x, y: y)
//          //nodes += [sp]
//          scene.addNode(sp)
//        }
//      }


//      (0...155).forEach { _ in
//        let sp = SpriteNode(texture: wall)
//        let x = Float(arc4random_uniform(500))
//        let y = Float(arc4random_uniform(300))
//        sp.position = Point(x: x, y: y)
//        nodes += [sp]
//        scene.addNode(sp)
//      }




//      let sp = SpriteNode(texture: wall)
//      sp.position = Point(x: 0.0, y: 0.0)
//      sp.name = "wall"
//      scene.addNode(sp)
//
//      let sp2 = SpriteNode(texture: floor)
//      sp2.position = Point(x: 64.0, y: 0.0)
//      sp2.name = "floor"
//      scene.addNode(sp2)
//
//      let sp3 = SpriteNode(texture: openDoor)
//      sp3.position = Point(x: Float(sp3.size.width * 2), y: 0.0)
//      sp3.name = "open door"
//      scene.addNode(sp3)
//
//      let sp4 = SpriteNode(texture: stairsDown)
//      sp4.position = Point(x: Float(sp4.size.width * 3), y: 0.0)
//      sp4.name = "stairs down"
//      scene.addNode(sp4)
//
//      let sp5 = SpriteNode(texture: stairsUp)
//      sp5.position = Point(x: Float(sp5.size.width * 4), y: 0.0)
//      sp5.name = "stairs up"
//      scene.addNode(sp5)
    }

    //    let texture = Texture(imageName: "Knight")
    //    let sp = SpriteNode(texture: texture, size: size)
    //    sp.position = (0.0, 0.0)
    //    let sp2 = SpriteNode(texture: texture, size: size)
    //    sp2.position = (10.0, 0.0)
    //    let sp3 = SpriteNode(texture: texture, size: size)
    //    sp3.position = (20.0, 0.0)
    //    scene.addNode(sp)
    //    scene.addNode(sp2)
    //    scene.addNode(sp3)

    //    let testText = TextLabel(text: "wtf test test", font: UIFont.boldSystemFontOfSize(32), color: UIColor.orangeColor())
    //    testText.name = "test text"
    //    scene.addNode(testText)
    //
    let colorRect = ShapeNode(width: 64, height: 64, color: .gray)
    colorRect.name = "Gray rect"
    colorRect.anchorPoint = Point(x: 0.5, y: 0.5)
    colorRect.position = Point(x: 50, y: 50)

    let action = Action.rotateBy(Float(360.0), duration: 1.0)
    //let action = Action.moveTo(100.0, y: 0.0, duration: 1.0)
    //let action = Action.moveTo(CGPoint(x: 0.0, y: 0.0), duration: 1.0)
    let forever = Action.repeatForever(action)
    //colorRect.runAction(forever)

    scene.addUINode(colorRect)

    let colorRect2 = ShapeNode(width: 64, height: 64, color: .red)
    colorRect2.name = "Red rect"
    colorRect2.position = Point(x: -128.0, y: -64.0)
    //colorRect2.anchorPoint = Point(x: -1.0, y: -1.0)
    colorRect2.zPosition = 0
    scene.addNode(colorRect2)

//    let colorRect3 = ShapeNode(width: 100, height: 100, color: .blue)
//    colorRect3.name = "blue rect"
//    //colorRect3.position = Point(x: 100, y: 50)
//    //colorRect3.anchorPoint = Point(x: 0.5, y: 0.5)
//    colorRect3.zPosition = 0
//    colorRect2.addNode(colorRect3)

    //let translate1 = Action.moveBy(150, y: 0.0, duration: 1.0)
    //let translate2 = Action.moveBy(-150, y: 0.0, duration: 1.0)
    //let group = Action.sequence([translate1, translate2])
    //let forever2 = Action.repeatForever(group)
    //colorRect.runAction(group)
    //colorRect.runAction(forever2)


    //
    //    let texture = Texture(imageName: "Atlas")
    //    let sp = SpriteNode(texture: texture)
    //    sp.name = "bottom sprite"
    //    sp.scale = (10, 10)
    //    sp.position = (300, 300)
    //    scene.addNode(sp)
    //
    //    let texture2 = Texture(imageName: "Knight")
    //    let sp2 = SpriteNode(texture: texture2)
    //    sp2.size = CGSize(width: 10, height: 10)
    //    sp2.name = "top sprite"
    //    sp2.scale = (10, 10)
    //    sp2.position = (300, 356)
    //    sp2.zPosition = 1000
    //    scene.addNode(sp2)

    //scene.removeNode(sp2)

    addGestures()
  }
}

//tmp
extension TestGameViewController {
  func addGestures() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
    view.addGestureRecognizer(tap)

    let pan = UIPanGestureRecognizer(target: self, action: #selector(panCamera(_:)))
    view.addGestureRecognizer(pan)

    let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomCamera(_:)))
    view.addGestureRecognizer(pinch)
  }

  func tap(_ t: UITapGestureRecognizer) {
    let p = t.location(in: view)
    let r = scene.convertPointFromView(p.point)

    scene.nodesAtPoint(r).forEach {
      print($0.name ?? "")
      print($0.frame)
    }
  }

  func panCamera(_ p: UIPanGestureRecognizer) {
    var pos = p.translation(in: view)
    pos.x *= CGFloat(scene.camera.xScale)
    pos.y *= CGFloat(scene.camera.yScale)
    pos.x *= -1.0
    
    scene.camera.position += pos.point
    p.setTranslation(.zero, in: view)
  }

  func zoomCamera(_ p: UIPinchGestureRecognizer) {
    let scale = self.scene.camera.scale * Float(p.scale)
    let realScale = max(0.5, min(scale, 5.0));
    scene.camera.zoom = realScale
    p.scale = 1.0
  }
}
