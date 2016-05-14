//
//  RenderTree.swift
//  GameEngine
//
//  Created by Anthony Green on 5/14/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Foundation

public protocol RenderTree {
  var renderableNodes: Renderables { get }
  var allRenderables: Renderables { get }
}

extension RenderTree {
  public var allRenderables: Renderables {
    let allNodes = renderableNodes.flatMap { $0.allRenderables }
    return renderableNodes + allNodes
  }
}