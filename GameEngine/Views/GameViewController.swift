import Metal
//tmp typealias stuff I think
#if os(iOS)
  import UIKit
  public typealias VC = UIViewController
#else
  import Cocoa
  public typealias VC = NSViewController
#endif

/**
 The `GameViewController` is a controller for stuff. It probably won't do much but it's required for iOS. Pretty much just 
 set up the `GameView` and `Scene` from here. After that???
 
 A basic setup in viewDidLoad() would look something like 
 
 ````
 super.viewDidLoad()

 let view = self.view as! GameView
 scene = Scene(size: view.bounds.size)
 view.presentScene(scene)
 ````
 */
open class GameViewController: VC {
  #if os(macOS)
  open override var preferredContentSize: NSSize {
    didSet {
      let size = Size(width: Int(preferredContentSize.width), height: Int(preferredContentSize.height))
      (view as! GameView).updateDrawable(size: size)
    }
  }
  #endif

  override open func loadView() {
    view = GameView(frame: Screen.main.nativeBounds)
  }
}
