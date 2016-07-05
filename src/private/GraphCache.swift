//
//  GraphCache.swift
//  GameEngine
//
//  Created by Anthony Green on 5/21/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

final class GraphCache {
  private var updateNodes = Nodes()
  var allNodes: Nodes {
    return updateNodes
  }

  private(set) var shapeNodes = [ShapeNode]()
  private(set) var spriteNodes = [Int: [SpriteNode]]()
  private var spriteIndex = [Int: Int]()
  var bufferManager: BufferManager?
  private(set) var textNodes = [TextNode]()
  private(set) var lightNodes = [LightNode]()

  func addNode(node: Node) {
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
        lightNodes += [light]
      case _: break
      }
    }
  }
  
  private func removeNode(node: Node) {
    if let index = updateNodes.find(node) {
      guard let removed = updateNodes.removeAtIndex(index) as? Renderable else { return }

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
        lightNodes.remove(light)
      case _: break
      }
    }
  }
  
  func updateNodes<T : Node>(node: T?) {
    guard let node = node else { return }
    guard updateNodes.find(node) != nil else { return }
    
    (node as Node).allNodes.forEach {
      removeNode($0)
    }
    removeNode(node)
  }
  
  private func realignData(key: Int) {
    guard let nodes = spriteNodes[key] else { return }
    guard let buffer = bufferManager?[key] else { return }
    
    nodes.enumerate().forEach { i, node in
      node.index = i
      buffer.addData(node.quad.vertices, size: node.quad.size, offset: i * node.quad.size)
    }
    spriteIndex[key] = nodes.count
  }
  
  func updateNode(quad: Quad, index: Int, key: Int) {
    guard let buffer = bufferManager?[key] else { return }
    
    buffer.addData(quad.vertices, size: quad.size, offset: index)
  }
}
