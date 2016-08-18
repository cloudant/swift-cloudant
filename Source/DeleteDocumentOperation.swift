//
//  DeleteDocumentOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 12/04/2016.
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

 An operation to delete a document from a database.

 Example usage:
 ````
 let delete = DeleteDocumentOperation(id: "exampleDocId", revision: "1-examplerevid", databaseName: "exampledb") { (response, httpInfo, error) in
    if let error = error {
        NSLog("An error occured attemtping to delete a document")
    } else {
        NSLog("Document deleted with statusCode \(statusCode!)"
    }
 }
 client.add(delete)
 ````
 */
public class DeleteDocumentOperation: CouchDatabaseOperation, JSONOperation {

    /**
    
     Creates the operation
     - parameter id: the ID of the document to delete
     - parameter revision: the revision of the document to delete.
     - parameter databaseName: the name of the database which contains the document.
     - parameter completionHandler: optional handler to run when the operation completes.
     */
    public init(id: String, revision: String, databaseName: String, completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.id = id
        self.revision = revision
        self.databaseName = databaseName
        self.completionHandler = completionHandler
    }
    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    public let databaseName: String

    /**
    The revision of the document to delete
     */
    public let revision: String

    /**
      The id of the document to delete.
     */
    public let id: String

    public var method: String {
        return "DELETE"
    }

    public var endpoint: String {
        return "/\(self.databaseName)/\(id)"
    }

    public var parameters: [String: String] {
        return ["rev": revision]
    }

}
