//
//  Screen.swift
//  GameEngine
//
//  Created by Anthony Green on 12/28/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
#if !os(macOS)
  import UIKit
  fileprivate typealias _Screen = UIScreen
#else
  import Cocoa
  fileprivate typealias _Screen = NSScreen
#endif

struct Screen {
  static let main = Screen()
  private let screen: _Screen

  var bounds: CGRect {
    #if !os(macOS)
      return screen.bounds
    #else
      return screen.frame
    #endif
  }

  var nativeBounds: CGRect {
    #if !os(macOS)
      let scale = screen.nativeScale
      var bounds = self.bounds
      bounds.size.width *= scale
      bounds.size.height *= scale
      return bounds
    #else
      return screen.frame
    #endif
  }

  init() {
    #if !os(macOS)
      screen = UIScreen.main
    #else
      guard let mainScreen = NSScreen.main else {
        fatalError("no screen tmp error, no idea why this would happen?")
      }
      screen = mainScreen
    #endif
  }
}
