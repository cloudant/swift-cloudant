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
     
     - parameter id: the id of the document to create or update
     - parameter revison: the revison of the document to update.
     - parameter body: the body of the document
     - parameter databaseName: the name of the database where the document will be created / updated.
     - parameter completionHandler: optional handler to run when the operation completes.
     */
    public init(id: String, revision: String? = nil, body: [String: AnyObject], databaseName:String, completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: Error?) -> Void)? = nil) {
        self.id = id;
        self.revision = revision
        self.body = body
        self.databaseName = databaseName
        self.completionHandler = completionHandler
        
    }
    
    public let completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: Error?) -> Void)?
    
    
    public let databaseName: String
    /**
     The document that this operation will modify.
     */
    public let id: String

    /**
     The revision of the document being updated or `nil` if this operation is creating a document.
     */
    public let revision: String?

    /** Body of document. Must be serialisable with NSJSONSerialization */
    public let body: [String: AnyObject]

    public func validate() -> Bool {
        #if os(Linux)
            return  NSJSONSerialization.isValidJSONObject(body!.bridge())
        #else
            return JSONSerialization.isValidJSONObject(body as NSDictionary)
        #endif
    }

    public var method: String {
        return "PUT"
    }

    public private(set) var data: Data?

    public var endpoint: String {
        return "/\(self.databaseName)/\(id)"
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
        #if os(Linux)
            data = try NSJSONSerialization.data(withJSONObject: body.bridge(), options: NSJSONWritingOptions())
        #else
             data = try JSONSerialization.data(withJSONObject: body as NSDictionary, options: JSONSerialization.WritingOptions())
        #endif
    }

}
