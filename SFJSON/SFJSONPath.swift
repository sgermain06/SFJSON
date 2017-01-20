//
//  SFJSONPath.swift
//  SFJSON
//
//  Created by Simon Germain on 1/19/17.
//  Copyright © 2017 SquareFrog. All rights reserved.
//

import Foundation

infix operator =~

/**
 Parses a left-hand side parameter through a regular expression provided on the right-hand side.
 
 - Parameters:
 - value: The `String` value to be parsed
 - pattern: The regular expression pattern to parse the value with.
 - Throws: NSRegularExpression exception, if the regular expression is bad.
 - Returns: Matched results using `RegexMatchResult` struct.
 */
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

/**
 Struct used to implements IteratorProtocol for `RegexMatchResult`'s `makeIterator` method.
 */
struct RegexMatchCaptureGenerator : IteratorProtocol {
    
    /**
     next() implementation for `IteratorProtocol` conformity
     
     - Returns: Optional `String`, if the items array slice isn't empty.
     */
    mutating func next() -> String? {
        if items.isEmpty { return nil }
        let ret = items[0]
        items = items[1..<items.count]
        return ret
    }
    
    /// Remaining items to recurse through. The `next()` method pops the first one and returns it.
    var items: ArraySlice<String>
}

/**
 Struct used to implements Sequence and stores the results of the regular expression matching.
 */
struct RegexMatchResult: Sequence {
    
    /// Array of items that were matched.
    var items: [String]
    
    /**
     makeIterator() implementation for `Sequence` conformity
     
     - Returns: RegexMatchCaptureGenerator that will allow the `Sequence` to use the `next()` method.
     */
    func makeIterator() -> RegexMatchCaptureGenerator {
        return RegexMatchCaptureGenerator(items: items[0..<items.count])
    }
    
    /**
     Convenience subscript method to return a specific item in the array of matched items
     
     - Parameter i: The index to fetch
     - Returns: The item matched at the provided index.
     */
    subscript (i: Int) -> String {
        return items[i]
    }
}

/**
 JSONPath class that will be responsible for parsing string paths for dictionary traversal.
 
 This class is internal to the SFJSON framework.
 */
class JSONPath {
    /// Path to parse
    let path: String
    /// Path components separated by a period.
    var pathComponents: [String] = []
    
    /**
     Initializes the JSONPath object by processing the path into the pathComponents property.
     
     - Parameter path: The `String` path to use for dictionary traversal
     */
    init(_ path: String) {
        self.path = path
        pathComponents = path.components(separatedBy: ".")
    }
    
    /**
     Fetches the first element from `pathComponents` for return and then remove it from the array.
     
     - Returns: The element that was removed from `pathComponents`. If none are left, return nil.
     */
    func nextKey() -> String? {
        
        guard !pathComponents.isEmpty else {
            return nil
        }
        
        return pathComponents.remove(at: 0)
    }
    
    /**
     Runs a provided key through the regular expression to return both the key to use in the dictionary as well as the array index, if one is found.
     
     - Parameter optionalKey: Key to run through the regular expression.
     - Throws: NSRegularExpression exception if the regular expression is bad.
     - Returns: Tuple containing a string value for the dictionary key and an optional integer if an array index was found in the key.
     */
    class func getArrayKeyAndIndex(_ optionalKey: String? = nil) throws -> (String?, Int?)? {
        
        if let key = optionalKey {
            var arrayKey: String?
            var arrayIndex: Int?
            var itr = 0
            
            for match in try key =~ "\\w+(?=\\[)|(?<=\\w\\[)(\\d+)(?=\\])" {
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
