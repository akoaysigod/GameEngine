//
//  GraphCache.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

final class GraphCache {
  fileprivate var updateNodes = Nodes()
  var allNodes: Nodes {
    return updateNodes
  }

  fileprivate(set) var shapeNodes = [ShapeNode]()
  fileprivate(set) var spriteNodes = [Int: [SpriteNode]]()
  fileprivate var spriteIndex = [Int: Int]()
  var bufferManager: BufferManager?
  fileprivate(set) var textNodes = [TextNode]()
  fileprivate(set) var lightNodes = [LightNode]()
  fileprivate var lightNodeIndex = 0

  func addNode(_ node: Node) {
    let allNodes = [node] + node.allNodes

    updateNodes += allNodes

    allNodes.forEach { node in
      switch node {
      case let shape as ShapeNode:
        shapeNodes += [shape]
      case let sprite as SpriteNode:
        let key = sprite.texture?.hashValue ?? -1
        if let arr = spriteNodes[key],
          let index = spriteIndex[key],
          let buffer = bufferManager?[key] {
          let newIndex = index + 1
          
          sprite.index = newIndex
          spriteIndex.updateValue(newIndex, forKey: key)
          spriteNodes.updateValue(arr + [sprite], forKey: key)
          
          buffer.addData(sprite.quad.vertices, size: sprite.quad.size, offset: newIndex)
        }
        else {
          sprite.index = 0
          spriteIndex.updateValue(0, forKey: key)
          spriteNodes.updateValue([sprite], forKey: key)
          
          let buffer = Buffer(length: sprite.quad.size * 500)
          buffer.addData(sprite.quad.vertices, size: sprite.quad.size)
          bufferManager?[key] = buffer
        }
      case let text as TextNode:
        textNodes += [text]
      case let light as LightNode:
        light.index = lightNodeIndex
        lightNodeIndex += 1
        lightNodes += [light]
      case _: break
      }
    }
  }
  
  fileprivate func removeNode(_ node: Node) {
    if let index = updateNodes.find(node) {
      guard let removed = updateNodes.remove(at: index) as? Renderable else { return }

      switch removed {
      case let shape as ShapeNode:
        shapeNodes.remove(shape)
      case let sprite as SpriteNode:
        let key = sprite.texture?.hashValue ?? -1
        if let arr = spriteNodes[key] {
          var arr = arr
          arr.remove(sprite)
          spriteNodes[key] = arr
          realignData(key)
        }
        else {
          DLog("Sprite was never cached?")
        }
      case let text as TextNode:
        textNodes.remove(text)
      case let light as LightNode:
        lightNodeIndex -= 1
        lightNodes.remove(light)
        //realignLightNodeData
      case _: break
      }
    }
  }
  
  func updateNodes<T : Node>(_ node: T?) {
    guard let node = node else { return }
    guard updateNodes.find(node) != nil else { return }
    
    (node as Node).allNodes.forEach {
      removeNode($0)
    }
    removeNode(node)
  }
  
  fileprivate func realignData(_ key: Int) {
    guard let nodes = spriteNodes[key] else { return }
    guard let buffer = bufferManager?[key] else { return }
    
    nodes.enumerated().forEach { i, node in
      node.index = i
      buffer.addData(node.quad.vertices, size: node.quad.size, offset: i * node.quad.size)
    }
    spriteIndex[key] = nodes.count
  }
  
  func updateNode(_ quad: Quad, index: Int, key: Int) {
    guard let buffer = bufferManager?[key] else { return }
    
    buffer.addData(quad.vertices, size: quad.size, offset: index)
  }
}
