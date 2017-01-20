//
//  SFJSONParser.swift
//  SFJSON
//
//  Created by Simon Germain on 1/19/17.
//  Copyright © 2017 SquareFrog. All rights reserved.
//

import Foundation

/**
 `JSONParser` class has two initializers. You can either initialize it using a `Data` object from `URLSession` or use a pre-existing dictionary.
 
 Initializing using data:
 
 ``
 let parser = try JSONParser(data: dataObject) // Using the Data type. Note the "try" call here, JSONSerialization can throw.
 ``
 
 Initialization using dictionary:
 
 ``
 let parser = JSONParser(dictionary: existingDictionary) // Note that this doesn't have a try call, nothing can throw here.
 ``
 */
public class JSONParser {
    
    private let json: [String: Any]?
    
    /**
     Initializes JSONParser using a `Data` object. The `Data` object will be parsed into a dictionary using `JSONSerialization`.
     
     - Parameter data: The data to parse into a dictionary
     - Throws: `NSJSONSerialization` exception if the parsing of the JSON string fails.
     */
    public init(data: Data) throws {
        
        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
    
    /**
     Initializes JSONParser using a pre-existing dictionary.
     
     - Parameter dictionary: The dictionary to use. It must be of type `[String: Any]`.
     */
    public init(dictionary: [String: Any]) {
        
        json = dictionary
    }
    
    /**
     Retrieve a value from the JSON dictionary at the provided path.
     ```
     let data = try parser.get("root.branches[2].item")
     ```
     - Parameter path:  The path where the data is using a string notation.
     - Throws:
     - Could throw on `JSONSerialization` if the parsing of the JSON string fails.
     - Could throw on `NSRegularExpression` if the parsing of the path fails.
     - Returns: The data requested as the `Any` type or nil if the data doesn't exist.
     */
    public func get(_ path: String) throws -> Any? {
        
        return try getJSONValue(json!, path: JSONPath(path))
    }
    
    /**
     Retrieve a `String` from the JSON dictionary at the provided path.
     ```
     let data = try parser.getString("root.branches[2].stringItem")
     ```
     - Parameter path:  The path where the data is using a string notation.
     - Throws:
     - Could throw on `JSONSerialization` if the parsing of the JSON string fails.
     - Could throw on `NSRegularExpression` if the parsing of the path fails.
     - Returns: The data requested as a `String` or nil if the data doesn't exist.
     */
    public func getString(path: String) throws -> String? {
        return try get(path) as? String
    }
    
    /**
     Retrieve an `Int` from the JSON dictionary at the provided path.
     ```
     let data = try parser.getInt("root.branches[2].intItem")
     ```
     - Parameter path:  The path where the data is using a string notation.
     - Throws:
     - Could throw on `JSONSerialization` if the parsing of the JSON string fails.
     - Could throw on `NSRegularExpression` if the parsing of the path fails.
     - Returns: The data requested as an `Int` or nil if the data doesn't exist.
     */
    public func getInt(path: String) throws -> Int? {
        return try get(path) as? Int
    }
    
    /**
     Retrieve a `Double` from the JSON dictionary at the provided path.
     ```
     let data = try parser.getDouble("root.branches[2].doubleItem")
     ```
     - Parameter path:  The path where the data is using a string notation.
     - Throws:
     - Could throw on `JSONSerialization` if the parsing of the JSON string fails.
     - Could throw on `NSRegularExpression` if the parsing of the path fails.
     - Returns: The data requested as a `Double` or nil if the data doesn't exist.
     */
    public func getDouble(path: String) throws -> Double? {
        return try get(path) as? Double
    }
    
    /**
     Retrieve an array from the JSON dictionary at the provided path.
     ```
     let data = try parser.getArray("root.branches")
     ```
     - Parameter path:  The path where the data is using a string notation.
     - Throws:
     - Could throw on `JSONSerialization` if the parsing of the JSON string fails.
     - Could throw on `NSRegularExpression` if the parsing of the path fails.
     - Returns: The data requested as an array of `Any` type or nil if the data doesn't exist.
     */
    public func getArray(path: String) throws -> [Any]? {
        return try get(path) as? [Any]
    }
    
    /**
     Recurses through the JSON dictionary provided until it has reached the correct keypath.
     
     - Parameter:
     - json: The JSON dictionary to parse
     - path: The JSONPath object that contains the dictionary of keys to use for parsing
     - Throws:
     - Could throw on `JSONSerialization` if the parsing of the JSON string fails.
     - Could throw on `NSRegularExpression` if the parsing of the path fails.
     - Returns: The data requested as the `Any` type or nil if the data doesn't exist.
     */
    private func getJSONValue(_ json: Any, path: JSONPath) throws -> Any? {
        
        if let key = path.nextKey() {
            
            if let (arrayKey, arrayIndex) = try JSONPath.getArrayKeyAndIndex(key) {
                if arrayKey != nil && arrayIndex != nil {
                    if let array = (json as! [String: Any])[arrayKey!] as? [String: Any] {
                        let key = Array(array.keys)[arrayIndex!]
                        return try getJSONValue(array[key]! as! [String : Any], path: path)
                    }
                }
            }
            
            if let value: Any = (json as! [String: Any])[key] {
                return try getJSONValue(value, path: path)
            }
            else {
                return nil
            }
        }
        
        return json
    }
}
