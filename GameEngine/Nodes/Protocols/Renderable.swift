//
//  RenderNode.swift
//  GameEngine
//
//  Created by Anthony Green on 1/16/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation
import Metal
import QuartzCore
import simd
#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

typealias Renderables = [Renderable]

protocol Renderable: NodeGeometry, Tree {
  var texture: Texture? { get set }

  var color: Color { get set }

  var alpha: Float { get set }

  var hidden: Bool { get set }

  var isVisible: Bool { get }

  var quad: Quad { get }
}
