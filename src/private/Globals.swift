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

func DLog(messages: Any..., filename: NSString = #file, function: String = #function, line: Int = #line) {
  #if DEBUG
    let message = messages.reduce("") {
      "\($1) " + "\($0)\n"
    }
    print("\(NSDate()) [\(filename.lastPathComponent):\(line)] \(function)\n\(message)")
  #endif
}
