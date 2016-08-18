//
//  GetDocumentOperation.swift
//  SwiftCloudant
//
//  Created by Stefan Kruger on 04/03/2016.
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
 
 Gets a document from a database.
 
 Example useage:
 
 ```
 let getDoc = GetDocumentOperation(id:"example", databaseName:"exampledb"){ (response, httpInfo, error) in 
    if let error = error {
        // handle the error
    } else {
        // check the response code to determine if the request was successful.
    }
 }
 ```
 
 */
public class GetDocumentOperation: CouchDatabaseOperation, JSONOperation {
    public typealias Json = [String: Any]


    /**
     Creates the operation.
     
      - parameter id: the id of the document to get from the database.
      - parameter databaseName : the name of the database which contains the document
      - parameter includeRevisions : include information about previous revisions of the document
      - parameter revision: the revision of the document to get
      - parameter completionHandler: optional handler to run when the operation completes.
     */
    public init(id: String, databaseName:String, includeRevisions:Bool? = nil, revision: String? = nil, completionHandler:(([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.id = id
        self.databaseName = databaseName
        self.includeRevisions = includeRevisions
        self.revision = revision
        self.completionHandler = completionHandler
    }
    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    
    public let databaseName: String
    
    /**
     Include all revisions of the document.
     */
    public let includeRevisions: Bool?

    /**
     The revision of the document to get.
     */
    public let revision: String?

    /**
     The id of the document that this operation will retrieve.
     */
    public let id: String

    public var endpoint: String {
        return "/\(self.databaseName)/\(id)"
    }

    public var parameters: [String:  String] {
        get {
            var items: [String: String] = [:]

            if let revision = revision {
                items["rev"] = revision
            }

            if let includeRevisions = includeRevisions {
                items["revs"] = "\(includeRevisions)"
            }

            return items
        }
    }

}
