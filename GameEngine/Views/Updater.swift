import Foundation
import QuartzCore

#if !os(macOS)
  typealias DisplayLink = CADisplayLink
#else
  typealias DisplayLink = CVDisplayLink
#endif

final class Updater {
  private weak var gameView: GameView?
  fileprivate var previousTime = 0.0
  fileprivate var displayLink: DisplayLink?

  init(gameView: GameView) {
    self.gameView = gameView
    createDisplayLink()
  }

  fileprivate func update(time: Double) {
    if previousTime == 0.0 {
      previousTime = time
    }
    gameView?.update(delta: time - previousTime)
    previousTime = time
  }
}
extension Updater {
#if !os(macOS)
  func createDisplayLink() {
    displayLink = CADisplayLink(target: self, selector: #selector(newFrame(_:)))
    displayLink?.add(to: .main, forMode: .commonModes)
  }
  
  @objc private func newFrame(_ displayLink: CADisplayLink) {
    update(time: displayLink.timestamp)
  }
#else
  func createDisplayLink() {
    func callback(link: CVDisplayLink,
                  inNow: UnsafePointer<CVTimeStamp>, //wtf is this?
                  inOutputTime: UnsafePointer<CVTimeStamp>,
                  flagsIn: CVOptionFlags,
                  flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                  displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
      unsafeBitCast(displayLinkContext, to: Updater.self).update(time: CACurrentMediaTime())
      return kCVReturnSuccess
    }
  
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
    guard let displayLink = displayLink else {
      fatalError("Unable to create a CVDisplayLink?")
    }
    CVDisplayLinkSetOutputCallback(displayLink, callback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
    CVDisplayLinkStart(displayLink)
  }
#endif
}

