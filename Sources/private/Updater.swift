//
//  Updater.swift
//  GameEngine
//
//  Created by Anthony Green on 5/7/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import QuartzCore

@objc protocol ScreenRefresher {
  var timestamp: Double { get }
}

final class Updater {
  var scene: Scene?

  var timestamp: CFTimeInterval = 0.0
  @objc func update(_ screenRefresher: ScreenRefresher) {
    if timestamp == 0.0 {
      timestamp = screenRefresher.timestamp
    }

    var elapsedTime = screenRefresher.timestamp - self.timestamp
    //not sure how to deal with this if you hit a break point the timer gets off making it difficult to figure out what's going on
    #if DEBUG
//    if showFPS {
//      let comeBackToThis = 1
      //need to figure out how to "animate" text changes for this singular purpose

//      let time = elapsedTime > 0.0 ? elapsedTime : 1.0
//      currentScene.fpsText.text = "\(Int(1.0 / time))"
//      currentScene.fpsText.buildMesh(device!)
//      currentScene.fpsText.updateVertices(device!)
//    }

    if elapsedTime >= 0.02 {
      elapsedTime = 1.0 / 60.0
    }
    #endif
    
    timestamp = screenRefresher.timestamp
    scene?.update(elapsedTime)
  }
}

// MARK: iOS
#if os(iOS)
extension CADisplayLink: ScreenRefresher {}
#endif
