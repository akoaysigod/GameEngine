//
//  GameViewController.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import GLKit
import Metal
import MetalKit
import UIKit

public class GEViewController: UIViewController {
  var scene: GEScene!
  
  override public func loadView() {
    let device = MTLCreateSystemDefaultDevice()!
    self.view = GEView(frame: UIScreen.mainScreen().bounds, device: device)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    //let fontTest = FontAtlas(font: UIFont.systemFontOfSize(15.0))
    
    let view = self.view as! GEView
   //let imgView = UIImageView(image: fontTest.debugImage)
    //view.addSubview(imgView)
    self.scene = GEScene(size: view.bounds.size)
    view.presentScene(scene)

    let testText = GETextLabel(text: "test test test", font: UIFont.boldSystemFontOfSize(72), color: UIColor.whiteColor())
    scene.addNode(testText)
    
    
//    let colorRect = GEColorRect(width: 100, height: 100, color: UIColor.grayColor())
//    colorRect.zPosition = 1001
//    colorRect.anchorPoint = (0.5, 0.5)
//    //colorRect.rotation = 45
//    colorRect.x = 100
//    colorRect.y = 300
//    
//    let action = GEAction.rotateBy(Float(360.0), duration: 1.0)
//    let forever = GEAction.repeatForever(action)
//    //colorRect.runAction(forever)
//    
//    //scene.addNode(colorRect)
//    
//    let colorRect2 = GEColorRect(width: 100, height: 100, color: UIColor.redColor())
//    colorRect2.position = (50, 300)
//    colorRect2.anchorPoint = (0.5, 0.5)
//    //colorRect2.zPosition = 0
//    //colorRect.addNode(colorRect2)
//    //scene.addNode(colorRect2)
//    
    let sp = GESprite(imageName: "Test2")
    sp.scale = 10
    sp.position = (300, 300)
    self.scene.addNode(sp)
//    
//    let sp2 = GESprite(imageName: "Test2")
//    sp2.scale = 10
//    sp2.position = (300, 356)
//    sp2.zPosition = 1000
//    self.scene.addNode(sp2)
//    if let device = MTLCreateSystemDefaultDevice() {
//      let view = self.view as! MTKView
//      view.device = device
//
//      self.camera = GECamera(size: view.bounds.size)
//      self.renderer = Renderer(device: device, view: view)
//
//      let colorRect = GEColorRect(device: device, camera: self.camera, width: 100, height: 100, color: UIColor.grayColor())
//      colorRect.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//      colorRect.x = 100
//      colorRect.y = 100
//
//      let action = GEAction.rotateBy(360, duration: 1.0)
//      let action2 = GEAction.moveTo(100.0, y: 300.0, duration: 1.0)
//      colorRect.runAction(GEAction.group([action, action2]))
//
//      self.drawable.append(colorRect)
//
//      let spriteTest = GESprite(device: device, camera: self.camera, imageName: "")
//      spriteTest.zPosition = 1
//      spriteTest.scale = 5.0
//      spriteTest.x = 100
//      spriteTest.y = 100
//      let sTest1 = GEAction.scaleTo(2.0, y: 2.0, duration: 1.0)
//      let sTest2 = GEAction.scaleTo(10.0, y: 10.0, duration: 1.0)
//      let seq1 = GEAction.sequence([sTest1, sTest2])
//      spriteTest.runAction(seq1)
//
//      self.drawable.append(spriteTest)
//
//      let colorRect2 = GESprite(device: device, camera: self.camera, imageName: "")
//      colorRect2.zPosition = 1
//      colorRect2.scale = 5.0
//      colorRect2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//      colorRect2.x = 100
//      colorRect2.y = 100
//      let action4 = GEAction.rotateBy(360, duration: 1.0)
//      let scaleActionFirst = GEAction.scaleBy(20.0, duration: 1.0)
//      let action6 = GEAction.moveTo(300, y: 300, duration: 1.0)
//      let action7 = GEAction.moveTo(100, y: 100, duration: 1.0)
//      let scaleActionSecond = GEAction.scaleBy(-20.0, duration: 1.0)
//      let group1 = GEAction.group([action4, scaleActionFirst, action6])
//      let group2 = GEAction.group([action4, scaleActionSecond, action7])
//      let seq = GEAction.sequence([group1, group2])
//      colorRect2.runAction(seq)
//      self.drawable.append(colorRect2)
//
//      let colorRect3 = GEColorRect(device: device, camera: camera, width: 100, height: 100, color: UIColor.orangeColor())
//      colorRect3.anchorPoint = CGPoint(x: 1.0, y: 1.0)
//      colorRect3.x = 100
//      colorRect3.y = 100
//      let action3 = GEAction.rotateBy(360, duration: 1.0)
//      let action5 = GEAction.moveTo(400, y: 100, duration: 1.0)
//      colorRect3.runAction(GEAction.sequence([action3, action5]))
//      self.drawable.append(colorRect3)
//
//      self.timer = CADisplayLink(target: self, selector: "newFrame:")
//      self.timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
//    }
//    else {
//      print("Metal is not supported on this device")
//      self.view = UIView(frame: self.view.frame)
//      return
//    }

    self.addGestures()
  }
}



//tmp
extension GEViewController {
  func addGestures() {
    let pan = UIPanGestureRecognizer(target: self, action: "panCamera:")
    self.view.addGestureRecognizer(pan)

    let pinch = UIPinchGestureRecognizer(target: self, action: "zoomCamera:")
    self.view.addGestureRecognizer(pinch)
  }

  func panCamera(p: UIPanGestureRecognizer) {
    let t = p.translationInView(self.view)
    
    let tMax: CGFloat = 3.0
    let tMin: CGFloat = -3.0
    
    let xMin = t.x > 0 ? tMax : tMin
    let yMin = t.y > 0 ? tMax : tMin
   
    self.scene.camera.x += t.x > 0 ? Float(min(t.x, xMin)) : Float(max(t.x, xMin))
    self.scene.camera.y += t.y > 0 ? Float(min(t.y, yMin)) : Float(max(t.y, yMin))
  }

  func zoomCamera(p: UIPinchGestureRecognizer) {
    let scale = self.scene.camera.scale * Float(p.scale)
    let realScale = max(0.5, min(scale, 5.0));
    self.scene.camera.scale = realScale
    p.scale = 1.0
  }
}
