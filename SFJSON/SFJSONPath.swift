//
//  SFJSONPath.swift
//  SFJSON
//
//  Created by Simon Germain on 1/19/17.
//  Copyright © 2017 SquareFrog. All rights reserved.
//

import Foundation

infix operator =~

func =~ (value : String, pattern : String) throws -> RegexMatchResult {

    let nsstr = value as NSString // we use this to access the NSString methods like .length and .substringWithRange(NSRange)
    let re = try NSRegularExpression(pattern: pattern, options: [])

    let all = NSRange(location: 0, length: nsstr.length)
    var matches = [String]()
    
    re.enumerateMatches(in: value, options: [], range: all) { (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, ptr: UnsafeMutablePointer<ObjCBool>) in
        if let result = result {
            let string = nsstr.substring(with: result.range)
            matches.append(string)
        }
    }
    return RegexMatchResult(items: matches)
}

struct RegexMatchCaptureGenerator : IteratorProtocol {
    
    mutating func next() -> String? {
        if items.isEmpty { return nil }
        let ret = items[0]
        items = items[1..<items.count]
        return ret
    }
    
    var items: ArraySlice<String>
}

struct RegexMatchResult: Sequence {
    
    var items: [String]
    
    func makeIterator() -> RegexMatchCaptureGenerator {
        return RegexMatchCaptureGenerator(items: items[0..<items.count])
    }
    
    var boolValue: Bool {
        return items.count > 0
    }
    
    subscript (i: Int) -> String {
        return items[i]
    }
}

class JSONPath {
    let path: String
    var pathComponents: [String] = []
    
    init(_ path: String) {
        self.path = path
        pathComponents = path.components(separatedBy: ".")
    }
    
    func nextKey() -> String? {
        
        guard !pathComponents.isEmpty else {
            return nil
        }
        
        return pathComponents.remove(at: 0)
    }
    
    class func getArrayKeyAndIndex(_ optionalKey: String? = nil) throws -> (String?, Int?)? {
        
        if let key = optionalKey {
            var arrayKey: String?
            var arrayIndex: Int?
            var itr = 0
            
            for match in try key =~ "\\w+(?=\\[)|(?<=\\w\\[)(\\d+)(?=\\]" {
                if (itr == 0) {
                    arrayKey = match
                }
                else {
                    arrayIndex = Int(match)
                }
                itr += 1
            }
            return (arrayKey, arrayIndex)
        }
        
        return nil
    }
}
