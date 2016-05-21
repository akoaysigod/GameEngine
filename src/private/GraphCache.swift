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
  private(set) var textNodes = [TextNode]()

  func addNode(node: Node) {
    let allNodes = [node] + node.allNodes

    updateNodes += allNodes

    allNodes.forEach {
      if $0 is Renderable {
        if let shape = $0 as? ShapeNode {
          shapeNodes += [shape]
        }
        else if let sprite = $0 as? SpriteNode {
          let key = sprite.texture?.hashValue ?? -1
          if let arr = spriteNodes[key] {
            spriteNodes.updateValue(arr + [sprite], forKey: key)
          }
          else {
            spriteNodes.updateValue([sprite], forKey: key)
          }
        }
        else if let text = $0 as? TextNode {
          textNodes += [text]
        }
      }
    }
  }

  private func removeNode(node: Node) {
    if let index = updateNodes.find(node) {
      guard let removed = updateNodes.removeAtIndex(index) as? Renderable else { return }
      
      if let shape = removed as? ShapeNode {
        shapeNodes.remove(shape)
      }
      else if let sprite = removed as? SpriteNode {
        let key = sprite.texture?.hashValue ?? -1
        if let arr = spriteNodes[key] {
          var arr = arr
          arr.remove(sprite)
          spriteNodes[key] = arr
        }
        else {
          DLog("Sprite was never cached?")
        }
      }
      else if let text = removed as? TextNode {
        textNodes.remove(text)
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
}