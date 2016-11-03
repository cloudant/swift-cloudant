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
 let allDocs = GetAllDocsOperation(databaseName: "exampleDB",
        rowHandler: { doc in
            print("Got document: \(doc)")
        }) { response, info, error in
                if let error = error {
                    // handle error
                } else {
                    // handle successful response
            }
 }
 client.add(operation: allDocs)
 ```
 */
public class GetAllDocsOperation : CouchOperation, ViewOperation, JSONOperation {
    public typealias Json = [String : Any]

    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    
    public let rowHandler: (([String: Any]) -> Void)?
    
    public let databaseName: String
    
    public let descending: Bool?
    
    public let endKey: String?
    
    public let includeDocs: Bool?
    
    public let conflicts: Bool?

    public let inclusiveEnd: Bool?

    public let key: String?
    
    public let keys: [String]?
    
    public let limit: UInt?
    
    public let skip: UInt?
    
    public let startKeyDocumentID: String?
    
    public let endKeyDocumentID: String?
    
    public let stale: Stale?
    
    public let startKey: String?
    
    public let includeLastUpdateSequenceNumber: Bool?
    
    /**
     Creates the operation
     
     - parameter databaseName: The name of the database from which to get all the documents.
     - parameter descending: Should the documents be sorted in descending order.
     - parameter endKey: When this document ID is hit stop returning results.
     - parameter includeDocs: Include document content in the response.
     - parameter conflicts: Include infomration about conflicted revisions.
     - parameter key: Return the document with the specified ID.
     - parameter keys: Return the documents with the soecified IDs.
     - parameter limit: The number of documents the repsonse should be limited to.
     - parameter skip: the number of documents that should be skipped before returning results.
     - parameter startKeyDocumentID: the document ID from which to start the response.
     - parameter endKeyDocumentID: the document ID at which to to stop retuning results.
     - parameter includeLastUpdateSequenceNumber: Include the sequence number at which the view was last updated.
     - parameter inclusiveEnd: Detmerines if the `endKey` and `endKeyDocId` should be included when returning documents.
     - parameter stale: Whether stale views are ok, or should be updated after the response is returned.
     - parameter startKey: the document ID from where to start returning documents.
     - parameter rowHandler: a handler to call for each row returned from the view.
     - parameter completionHandler: optional handler to call when the operation completes.
     
     - warning: `stale` is an advanced option, it should not be used unless you fully understand the outcome of changing the value of this property.
     - warning: The option `key` and `keys` cannot be used together.
     */
    public init(databaseName: String,
                descending: Bool? = nil,
                endKey: String? = nil,
                includeDocs: Bool? = nil,
                conflicts: Bool? = nil,
                key: String? = nil,
                keys: [String]? = nil,
                limit: UInt? = nil,
                skip: UInt? = nil,
                startKeyDocumentID: String? = nil,
                endKeyDocumentID: String? = nil,
                stale: Stale? = nil,
                startKey: String? = nil,
                includeLastUpdateSequenceNumber: Bool? = nil,
                inclusiveEnd: Bool? = nil,
                rowHandler: (([String: Any]) -> Void)? = nil,
                completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil){
        
        self.databaseName = databaseName
        self.descending = descending
        self.endKey = endKey
        self.includeDocs = includeDocs
        self.conflicts = conflicts
        self.key = key
        self.keys = keys
        self.limit = limit
        self.skip = skip
        self.startKeyDocumentID = startKeyDocumentID
        self.stale = stale
        self.startKey = startKey
        self.includeLastUpdateSequenceNumber = includeLastUpdateSequenceNumber
        self.endKeyDocumentID = endKeyDocumentID
        self.rowHandler = rowHandler
        self.completionHandler = completionHandler
        self.inclusiveEnd = inclusiveEnd
    }
    
    private var jsonData: Data?
    
    
    public func validate() -> Bool {
        
        if conflicts != nil && includeDocs != true {
            return false
        }
        
        if keys != nil && key != nil {
            return false
        }
        
        return true
    }
    
    public var endpoint: String {
        return "/\(databaseName)/_all_docs"
    }
    
    public var parameters: [String : String] {
        get {
            var params:[String: String] = makeParams()
            
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
            keyJson = try jsonValue(for: key)
        }
        if let endKey = endKey {
            endKeyJson = try jsonValue(for: endKey)
        }
        
        if let startKey = startKey {
            startKeyJson = try jsonValue(for: startKey)
        }
    }
    
    public var data: Data? {
        return jsonData
    }
    
}

