//
//  Updater.swift
//  GameEngine
//
//  Created by Anthony Green on 5/7/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import QuartzCore

final class Updater {
  private weak var gameView: GameView?
  private var previousTime = 0.0

  #if os(iOS)
  private var displayLink: CADisplayLink!
  #else
  private var displayLink: CVDisplayLink?
  #endif

  init(gameView: GameView) {
    self.gameView = gameView

    #if !os(macOS)
      displayLink = CADisplayLink(target: self, selector: #selector(newFrame(_:)))
      displayLink.add(to: .main, forMode: .commonModes)
    #else
      func callback(link: CVDisplayLink,
                    inNow: UnsafePointer<CVTimeStamp>, //wtf is this?
                    inOutputTime: UnsafePointer<CVTimeStamp>,
                    flagsIn: CVOptionFlags,
                    flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                    displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
        unsafeBitCast(displayLinkContext, to: Updater.self).update(time: CACurrentMediaTime())
        return kCVReturnSuccess
      }

      CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
      guard let displayLink = displayLink else {
        fatalError("Unable to create a CVDisplayLink?")
      }
      CVDisplayLinkSetOutputCallback(displayLink, callback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
      CVDisplayLinkStart(displayLink)
    #endif
  }

  func update(time: Double) {
    if previousTime == 0.0 {
      previousTime = time
    }
    gameView?.update(delta: time - previousTime)
    previousTime = time
  }

  #if !os(macOS)
  @objc private func newFrame(_ displayLink: CADisplayLink) {
    update(time: displayLink.timestamp)
  }
  #endif
}
