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
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("This device probably doesn't support Metal or I don't know why this failed")
    }
    self.view = GEView(frame: UIScreen.mainScreen().bounds, device: device)
    self.view.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    //let fontTest = FontAtlas(font: UIFont.systemFontOfSize(15.0))
    
    let view = self.view as! GEView
    self.scene = GEScene(size: view.bounds.size)
    view.presentScene(scene)

    //let testText = GETextLabel(text: "test test test", font: UIFont.boldSystemFontOfSize(32), color: UIColor.whiteColor())
    //scene.addNode(testText)
    
    let colorRect = GEColorRect(width: 100, height: 100, color: UIColor.grayColor())
    colorRect.name = "Gray rect"
    colorRect.zPosition = 1001
    colorRect.anchorPoint = (0.5, 0.5)
    colorRect.x = 100
    colorRect.y = 300
    
    let action = GEAction.rotateBy(Float(360.0), duration: 1.0)
    let forever = GEAction.repeatForever(action)
    colorRect.runAction(forever)
    scene.addNode(colorRect)

    let colorRect2 = GEColorRect(width: 100, height: 100, color: UIColor.redColor())
    colorRect2.name = "Red rect"
    colorRect2.position = (50, 300)
    colorRect2.anchorPoint = (0.5, 0.5)
    colorRect2.zPosition = 0
let fixthisnext = 1 //this shouldn't need to be added twice, I don't know if it's always been this way or since I refactored the node tree stuff
                    //the node tree needs to be addeed to the scene anyway
    colorRect.addNode(colorRect2) 

    let sp = GESprite(imageName: "Test2")
    sp.name = "bottom sprite"
    sp.scale = (10, 10)
    sp.position = (300, 300)
    self.scene.addNode(sp)

    let sp2 = GESprite(imageName: "Test2")
    sp2.name = "top sprite"
    sp2.scale = (10, 10)
    sp2.position = (300, 356)
    sp2.zPosition = 1000
    self.scene.addNode(sp2)

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
