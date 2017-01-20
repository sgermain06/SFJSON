//
//  SFJSONParser.swift
//  SFJSON
//
//  Created by Simon Germain on 1/19/17.
//  Copyright © 2017 SquareFrog. All rights reserved.
//

import Foundation

public class JSONParser {
    
    private let json: [String: Any]?
    
    init(_ data: Data) throws {
        
        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
    
    public func get(_ path: String) throws -> Any? {
        
        return try getJSONValue(json!, path: JSONPath(path))
    }
    
    public func getString(path: String) throws -> String? {
        return try get(path) as? String
    }
    
    public func getInt(path: String) throws -> Int? {
        return try get(path) as? Int
    }
    
    public func getDouble(path: String) throws -> Double? {
        return try get(path) as? Double
    }
    
    public func getArray(path: String) throws -> [Any]? {
        return try get(path) as? [Any]
    }
    
    private func getJSONValue(_ json: [String: Any], path: JSONPath) throws -> [String: Any]? {
        
        if let key = path.nextKey() {
            
            if let (arrayKey, arrayIndex) = try JSONPath.getArrayKeyAndIndex(key) {
                if arrayKey != nil && arrayIndex != nil {
                    if let array = json[arrayKey!] as? [String: Any] {
                        let key = Array(array.keys)[arrayIndex!]
                        return try getJSONValue(array[key]! as! [String : Any], path: path)
                    }
                }
            }
            
            if let value: Any = json[key] {
                return try getJSONValue(value as! [String : Any], path: path)
            }
            else {
                return nil
            }
        }
        
        return json
    }
}
