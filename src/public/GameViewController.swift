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
    
    let view = self.view as! GameView
    view.delegate = self
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
