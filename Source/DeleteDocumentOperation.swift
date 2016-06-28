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
 let delete = DeleteDocumentOperation()
 delete.docId = "exampleDocId"
 delete.revId = "1-examplerevid"
 delete.databaseName = "exampledb"
 delete.completionHandler = { (response, httpInfo, error) in
    if let error = error {
        NSLog("An error occured attemtping to delete a document")
    } else {
        NSLog("Document deleted with statusCode \(statusCode!)"
    }
 }
 client.add(delete)
 ````
 */
public class DeleteDocumentOperation: CouchDatabaseOperation, JsonOperation {

    public init() { }
    
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HttpInfo?, error: ErrorProtocol?) -> Void)?
    public var databaseName: String?

    /**
     * The revision of the document to delete
     *
     * **Must** be set before an operation can succesfully execute.
     */
    public var revId: String? = nil

    /**
     * The id of the document to delete.
     *
     * **Must** be set before an operation can succesfully execute.
     */
    public var docId: String? = nil

    public func validate() -> Bool {
        return databaseName != nil  && revId != nil && docId != nil
    }

    public var method: String {
        return "DELETE"
    }

    public var endpoint: String {
        return "/\(self.databaseName!)/\(docId!)"
    }

    public var parameters: [String: String] {
        return ["rev": revId!]
    }

}
