import Foundation

let BUFFER_SIZE = 3

func DLog(_ messages: Any..., filename: NSString = #file, function: String = #function, line: Int = #line) {
  #if DEBUG
    let message = messages.reduce("") {
      "\($1) " + "\($0)\n"
    }
    print("\(NSDate()) [\(filename.lastPathComponent):\(line)] \(function)\n\(message)")
  #endif
}
