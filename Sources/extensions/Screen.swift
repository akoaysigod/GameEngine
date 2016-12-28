//
//  Screen.swift
//  GameEngine
//
//  Created by Anthony Green on 12/28/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

struct Screen {
  static let main = Screen()
  #if os(iOS)
  let screen: UIScreen
  #else
  let screen: NSScreen
  #endif

  var bounds: CGRect {
    #if os(iOS)
    return screen.bounds
    #else
    return screen.frame
    #endif
  }

  init() {
    #if os(iOS)
    screen = UIScreen.main
    #else
    guard let mainScreen = NSScreen.main() else {
      assertionFailure("No screen available?"); return
    }
    screen = mainScreen
    #endif
  }
}
