//
//  GameViewController.swift
//  MKTest
//
//  Created by Tony Green on 12/23/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import GLKit
import Metal
import MetalKit
import UIKit

public class GEViewController: UIViewController {
  var camera: GECamera!
  
  override public func loadView() {
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("This device does not support metal.")
    }
    
    self.view = GEView(frame: UIScreen.mainScreen().bounds, device: device)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    let view = self.view as! GEView
    let scene = GEScene(size: view.bounds.size)
    view.presentScene(scene)
    
    let colorRect = GEColorRect(width: 100, height: 100, color: UIColor.grayColor())
    colorRect.x = 100
    colorRect.y = 100
    scene.addNode(colorRect)
    
//    let colorRect2 = GEColorRect(width: 50, height: 50, color: UIColor.redColor())
//    colorRect.zPosition = 1
//    colorRect.addChild(colorRect2)
//    scene.addChild(colorRect2)
    
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

//    self.addGestures()
  }
}



//tmp
extension GEViewController {
//  func addGestures() {
//    let pan = UIPanGestureRecognizer(target: self, action: "panCamera:")
//    self.view.addGestureRecognizer(pan)
//
//    let pinch = UIPinchGestureRecognizer(target: self, action: "zoomCamera:")
//    self.view.addGestureRecognizer(pinch)
//  }
//
//  func panCamera(p: UIPanGestureRecognizer) {
//    let t = p.translationInView(self.view)
//    if t.x > 0.0 {
//      self.camera.x -= 1
//    }
//    else {
//      self.camera.x += 1
//    }
//
//    if t.y > 0.0 {
//      self.camera.y += 1
//    }
//    else {
//      self.camera.y -= 1
//    }
//  }
//
//  func zoomCamera(p: UIPinchGestureRecognizer) {
//    self.camera.zoom = Float(p.scale)
//  }
}
