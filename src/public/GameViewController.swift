//
//  GameViewController.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Metal
import MetalKit
import UIKit

/**
 The `GameViewController` is responsible for mainly the game/rendering loop. 
 
 A basic setup in viewDidLoad() would look something like 
 
 ````
 super.viewDidLoad()

 let view = self.view as! GameView
 scene = Scene(size: view.bounds.size)
 view.presentScene(scene)
 ````
 */
public class GameViewController: UIViewController {
  var scene: Scene!

  private var currentTime = 0.0

  override public func loadView() {
    view = GameView(frame: UIScreen.mainScreen().bounds, device: Device.shared.device)
    view.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    //let fontTest = FontAtlas(font: UIFont.systemFontOfSize(15.0))


    let view = self.view as! GameView
    view.delegate = self
    scene = Scene(size: view.bounds.size)
    view.presentScene(scene)

    if let environmentAtlas = TextureAtlas(named: "Environment"),
       let wall = environmentAtlas.textureNamed("Wall"),
       let floor = environmentAtlas.textureNamed("Floor"),
       let openDoor = environmentAtlas.textureNamed("OpenDoor"),
       let stairsDown = environmentAtlas.textureNamed("StairsDown"),
       let stairsUp = environmentAtlas.textureNamed("StairsUp") {
      let sp = SpriteNode(texture: wall)
      sp.position = (0.0, 0.0)
      scene.addNode(sp)

      let sp2 = SpriteNode(texture: floor)
      sp2.position = (Float(sp2.size.width), 0.0)
      scene.addNode(sp2)

      let sp3 = SpriteNode(texture: openDoor)
      sp3.position = (Float(sp3.size.width * 2), 0.0)
      scene.addNode(sp3)

      let sp4 = SpriteNode(texture: stairsDown)
      sp4.position = (Float(sp4.size.width * 3), 0.0)
      scene.addNode(sp4)

      let sp5 = SpriteNode(texture: stairsUp)
      sp5.position = (Float(sp5.size.width * 4), 0.0)
      scene.addNode(sp5)
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
    let colorRect = ShapeNode(width: 100, height: 100, color: UIColor.grayColor())
    colorRect.name = "Gray rect"
    colorRect.anchorPoint = (0.5, 0.5)
    colorRect.x = 100
    colorRect.y = 300
    
    let action = Action.rotateBy(Float(360.0), duration: 1.0)
    //let action = Action.moveBy(10.0, y: 0.0, duration: 1.0)
    //let action = Action.moveTo(CGPoint(x: 0.0, y: 0.0), duration: 1.0)
    let forever = Action.repeatForever(action)
    colorRect.runAction(forever)
    scene.addNode(colorRect)

    let colorRect2 = ShapeNode(width: 100, height: 100, color: UIColor.redColor())
    colorRect2.name = "Red rect"
    colorRect2.position = (50, 300)
    colorRect2.anchorPoint = (0.5, 0.5)
    colorRect2.zPosition = 0
    colorRect.addNode(colorRect2)

    //let translate1 = Action.moveBy(150, y: 0.0, duration: 1.0)
    //let translate2 = Action.moveBy(-150, y: 0.0, duration: 2.0)
    //let group = Action.group([translate1, translate2])
    //let forever2 = Action.repeatForever(group)
    //colorRect.runAction(group)

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

extension GameViewController: MTKViewDelegate {
  public func drawInMTKView(view: MTKView) {
    let cTime = CACurrentMediaTime()

    if currentTime == 0.0 {
      currentTime = cTime
    }
    let eTime = cTime - currentTime
    currentTime = cTime

    scene.update(eTime)
  }

  public func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {}
}


//tmp
extension GameViewController {
  func addGestures() {
    let pan = UIPanGestureRecognizer(target: self, action: #selector(panCamera(_:)))
    self.view.addGestureRecognizer(pan)

    let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomCamera(_:)))
    self.view.addGestureRecognizer(pinch)
  }

  func panCamera(p: UIPanGestureRecognizer) {
    let t = p.translationInView(self.view)
    
    let tMax: CGFloat = 3.0
    let tMin: CGFloat = -3.0
    
    let xMin = t.x > 0 ? tMax : tMin
    let yMin = t.y > 0 ? tMax : tMin
   
    self.scene.camera?.x += t.x > 0 ? Float(min(t.x, xMin)) : Float(max(t.x, xMin))
    self.scene.camera?.y += t.y > 0 ? Float(min(t.y, yMin)) : Float(max(t.y, yMin))
  }

  func zoomCamera(p: UIPinchGestureRecognizer) {
    let scale = self.scene.camera!.scale * Float(p.scale)
    let realScale = max(0.5, min(scale, 5.0));
    self.scene.camera!.scale = realScale
    p.scale = 1.0
  }
}
