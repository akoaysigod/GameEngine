//
//  GERenderPassQueue.swift
//  MKTest
//
//  Created by Tony Green on 12/30/15.
//  Copyright © 2015 Tony Green. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class RenderPassQueue {
  private let view: MTKView
  var queue: [MTLRenderPassDescriptor]

  var currentDrawable: CAMetalDrawable? {
    return self.view.currentDrawable
  }

  private var currentDescriptorIndex = 0

  init(view: MTKView, queueSize: Int = 2) {
    self.view = view
    self.queue = [MTLRenderPassDescriptor]()

    assert(queueSize >= 1)

    let firstPass = MTLRenderPassDescriptor()
    firstPass.colorAttachments[0].loadAction = .Clear
    firstPass.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
    firstPass.colorAttachments[0].storeAction = .Store
    self.queue.append(firstPass)

    (1..<queueSize).forEach { i in
      let passDescriptor = createPassDescriptor(i >= queueSize)
      self.queue.append(passDescriptor)
    }
  }

  func createPassDescriptor(isLastPass: Bool) -> MTLRenderPassDescriptor {
    let passDescriptor = MTLRenderPassDescriptor()
    passDescriptor.colorAttachments[0].loadAction = .Load
    passDescriptor.colorAttachments[0].storeAction = isLastPass ? .DontCare : .Store
    return passDescriptor
  }

  func next() -> MTLRenderPassDescriptor {
    let descriptor = queue[self.currentDescriptorIndex]
    descriptor.colorAttachments[0].texture = self.currentDrawable?.texture

    self.currentDescriptorIndex = (self.currentDescriptorIndex + 1) % self.queue.count

    return descriptor
  }
}
