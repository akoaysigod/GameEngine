//
//  ChildProtocol.swift
//  GameEngine
//
//  Created by Anthony Green on 1/10/16.
//  Copyright © 2016 Tony Green. All rights reserved.
//

import Foundation

public protocol ParentChild {
  func addChild(child: ParentChild)
  func removeChild(child: ParentChild)
}