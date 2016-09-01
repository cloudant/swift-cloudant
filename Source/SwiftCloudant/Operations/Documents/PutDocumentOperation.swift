//
//  PutDocumentOperation.swift
//  SwiftCloudant
//
//  Created by stefan kruger on 05/03/2016.
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
 Creates or updates a document.
 
 Usage example:
 
 ```
 let create = PutDocumentOperation(id: "example", body: ["hello":"world"], databaseName: "exampleDB") { (response, httpInfo, error) in 
    if let error = error {
        // handle the error
    } else {
        // successfull request.
    }
 }
 ```
 
 */
public class PutDocumentOperation: CouchDatabaseOperation, JSONOperation {
    
    /**
     Creates the operation.
     
     - parameter id: the id of the document to create or update, or nil if the server should generate an ID.
     - parameter revision: the revision of the document to update, or `nil` if it is a create.
     - parameter body: the body of the document
     - parameter databaseName: the name of the database where the document will be created / updated.
     - parameter completionHandler: optional handler to run when the operation completes.
     */
    public init(id: String? = nil, revision: String? = nil, body: [String: Any], databaseName:String, completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.id = id;
        self.revision = revision
        self.body = body
        self.databaseName = databaseName
        self.completionHandler = completionHandler
        
    }
    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    
    
    public let databaseName: String
    /**
     The document that this operation will modify.
     */
    public let id: String?

    /**
     The revision of the document being updated or `nil` if this operation is creating a document.
     */
    public let revision: String?

    /** Body of document. Must be serialisable with NSJSONSerialization */
    public let body: [String: Any]

    public func validate() -> Bool {
        return JSONSerialization.isValidJSONObject(body)
    }

    public var method: String {
        get {
            if let _ = id {
                return "PUT"
            } else {
                return "POST"
            }
        }
    }

    public private(set) var data: Data?

    public var endpoint: String {
        get {
            if let id = id {
                return "/\(self.databaseName)/\(id)"
            } else {
                return "/\(self.databaseName)"
            }
        }
        
    }

    public var parameters: [String: String] {
        get {
            var items:[String:String] = [:]

            if let revision = revision {
                items["rev"] = revision
            }
            
            return items
        }
    }
    
    public func serialise() throws {
        data = try JSONSerialization.data(withJSONObject: body)
    }

}
