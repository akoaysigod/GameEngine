final class GraphCache {
  fileprivate var updateNodes = Nodes()
  var allNodes: Nodes {
    return updateNodes
  }

  private(set) var shapeNodes = [ShapeNode]()
  private(set) var spriteNodes = [Int: [SpriteNode]]()
  private var spriteIndex = [Int: Int]()
  var bufferManager: BufferManager?
  private(set) var textNodes = [TextNode]()
  private(set) var lightNodes = [LightNode]()
  private var lightNodeIndex = 0

  func add(node: Node) {
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
          
          buffer.add(data: sprite.quad.vertices, size: sprite.quad.size, offset: newIndex)
        }
        else {
          sprite.index = 0
          spriteIndex.updateValue(0, forKey: key)
          spriteNodes.updateValue([sprite], forKey: key)

          //FIX THIS
          //bufferManager will definitely exist or this whole object is broken,
          //this api sucks though
          if let buffer = bufferManager?.makeBuffer(length: sprite.quad.size * 500) {
            buffer.add(data: sprite.quad.vertices, size: sprite.quad.size)
            bufferManager?[key] = buffer
          }
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
  
  private func remove(node: Node) {
    if let index = updateNodes.find(node) {
      guard let removed = updateNodes.remove(at: index) as? Renderable else { return }

      switch removed {
      case let shape as ShapeNode:
        _ = shapeNodes.remove(shape)
      case let sprite as SpriteNode:
        let key = sprite.texture?.hashValue ?? -1
        if let arr = spriteNodes[key] {
          var arr = arr
          _ = arr.remove(sprite)
          spriteNodes[key] = arr
          realignData(key: key)
        }
        else {
          DLog("Sprite was never cached?")
        }
      case let text as TextNode:
        _ = textNodes.remove(text)
      case let light as LightNode:
        lightNodeIndex -= 1
        _ = lightNodes.remove(light)
        //realignLightNodeData
      case _: break
      }
    }
  }
  
  func update<T : Node>(node: T?) {
    guard let node = node else { return }
    guard updateNodes.find(node) != nil else { return }
    
    (node as Node).allNodes.forEach {
      remove(node: $0)
    }
    remove(node: node)
  }
  
  private func realignData(key: Int) {
    guard let nodes = spriteNodes[key] else { return }
    guard let buffer = bufferManager?[key] else { return }
    
    nodes.enumerated().forEach { i, node in
      node.index = i
      buffer.add(data: node.quad.vertices, size: node.quad.size, offset: i * node.quad.size)
    }
    spriteIndex[key] = nodes.count
  }
  
  func updateNode(quad: Quad, index: Int, key: Int) {
    guard let buffer = bufferManager?[key] else { return }
    
    buffer.add(data: quad.vertices, size: quad.size, offset: index)
  }
}
