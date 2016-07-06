//
//  GetAllDocsOperation.swift
//  SwiftCloudant
//
//  Copyright (c) 2016 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import Foundation

/**
 An Operation to get all the documents in a database.
 
 Example usage:
 ```
 let allDocs = GetAllDocsOperation()
 allDocs.databaseName = "exampleDB"
 allDocs.docHandler = { doc in 
    print("Got document: \(doc)")
 }
 allDocs.completionHandler = { response, info, error in 
    if let error = error {
        // handle error
    } else {
        // handle successful response
    }
 }
 client.add(operation: allDocs)
 ```
 */
public class GetAllDocsOperation : CouchOperation, ViewOperation, JsonOperation {
    
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: ErrorProtocol?) -> Void)?
    
    public var rowHandler: ((row: [String: AnyObject]) -> Void)?
    
    public var databaseName: String?
    
    public var descending: Bool?
    
    public var endKey: String?
    
    public var includeDocs: Bool?
    
    public var conflicts: Bool?

    public var inclusiveEnd: Bool?

    public var key: String?
    
    public var keys: [String]?
    
    public var limit: UInt?
    
    public var skip: UInt?
    
    public var startKeyDocId: String?
    
    public var endKeyDocId: String?
    
    public var stale: Stale?
    
    public var startKey: String?
    
    public var updateSeq: Bool?
    
    public init(){}
    
    private var jsonData: Data?
    
    
    public func validate() -> Bool {
        if databaseName == nil {
            return false
        }
        
        if conflicts != nil && includeDocs != true {
            return false
        }
        
        if keys != nil && key != nil {
            return false
        }
        
        return true
    }
    
    public var endpoint: String {
        return "/\(databaseName!)/_all_docs"
    }
    
    public var parameters: [String : String] {
        get {
            var params:[String: String] = generateParams()
            
            if let endKeyJson = endKeyJson {
                params["endkey"] = endKeyJson
            }
            
            if let keyJson = keyJson {
                params["key"] = keyJson
            }
            
            if let startKeyJson = startKeyJson {
                params["startkey"] = startKeyJson
            }
            
            return params;
        }
    }
    
    private var keyJson: String?
    private var endKeyJson: String?
    private var startKeyJson: String?
    
    public func serialise() throws {
        if let keys = keys {
            jsonData = try JSONSerialization.data(withJSONObject: keys)
        }
        
        if let key = key {
            keyJson = try convertJson(key: key)
        }
        if let endKey = endKey {
            endKeyJson = try convertJson(key: endKey)
        }
        
        if let startKey = startKey {
            startKeyJson = try convertJson(key: startKey)
        }
    }
    
    public var data: Data? {
        return jsonData
    }
    
}

