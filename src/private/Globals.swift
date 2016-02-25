//
//  Globals.swift
//  MKTest
//
//  Created by Anthony Green on 12/30/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Foundation

typealias Data = [Float]
let FloatSize = sizeof(Float)

func DLog(messages: Any..., filename: NSString = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
  #if DEBUG
    let message = messages.reduce("") {
      "\($1) " + "\($0)\n"
    }
    print("\(NSDate()) [\(filename.lastPathComponent):\(line)] \(function)\n\(message)")
  #endif
}
