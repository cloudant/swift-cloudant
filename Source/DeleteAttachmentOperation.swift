//
//  DeleteAttachmentOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 17/05/2016.
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
 
 An Operation to delete an attachment from a document.
 
 Example usage:
 ```
 let deleteAttachment = DeleteAttachmentOperation(name: "myAwesomeAttachment",
                                            documentID: "exampleDocId",
                                             revision: "1-arevision",
                                          databaseName: "exampledb"){(response, info, error) in
    if let error = error {
    // handle the error
    } else {
    // process successful response
    }
 }
 client.add(operation: deleteAttachment)
 ```
 
 */
public class DeleteAttachmentOperation: CouchDatabaseOperation, JSONOperation {
    
    /**
    
     Creates the operation
    
     - parameter name : The name of the attachment to delete
     - parameter documentID : the ID of the document that the attachment is attached to.
     - parameter revision : the revision of the document that the attachment is attached to.
     - parameter databaseName : the name of the database that the contains the attachment.
     - parameter completionHandler: optional handler to run when the operation completes.
     */
    public init(name: String, documentID: String, revision: String, databaseName: String, completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.name = name
        self.documentID = documentID
        self.revision = revision
        self.databaseName = databaseName
        self.completionHandler = completionHandler
    }
    
    public let databaseName: String
    
    public let completionHandler: (( [String : Any]?, HTTPInfo?, Error?) -> Void)?
    
    /**
     The ID of the document that the attachment is attached to.
     
     */
    public let documentID: String
    
    /**
     The revision of the document that the attachment is attached to.
     */
    public let revision: String
    
    /**
     The name of the attachment.
     */
    public let name: String
    
    public var endpoint: String {
        return "/\(self.databaseName)/\(documentID)/\(name)"
    }
    
    public var parameters: [String: String] {
        return ["rev": revision]
    }
    
    public var method: String {
        return "DELETE"
    }
    
}
