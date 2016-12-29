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
#else
  import Cocoa
#endif

struct Screen {
  static let main = Screen()
  #if !os(macOS)
  let screen: UIScreen
  #else
  let screen: NSScreen
  #endif

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
    guard let mainScreen = NSScreen.main() else {
      //assertionFailure("No screen available?"); return
      fatalError("no screen tmp error")
    }
    screen = mainScreen
    #endif
  }
}
