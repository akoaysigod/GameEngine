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
import UIKit

typealias Renderables = [Renderable]

protocol Renderable: class, NodeGeometry, Tree {
  var texture: Texture? { get set }

  var color: Color { get set }

  var alpha: Float { get set }

  var hidden: Bool { get set }

  var isVisible: Bool { get }

  var quad: Quad { get }
}
