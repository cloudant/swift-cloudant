//
//  PutAttachmentOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 11/05/2016.
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
 
 An Operation to add an attachment to a document.
 
 Example usage:
 ```
 let attachment = "This is my awesome essay attachment for my document"
 let putAttachment = PutAttachmentOperation(name: "myAwsomeAttachment",
                                     contentType: "text/plain",
                                            data: attachment.data(using: .utf8, allowLossyConversion: false)
                                      documentID: docId
                                           revID: revID
                                    databaseName: "exampledb") {(response, info, error) in
                                                                        if let error = error {
                                                                            // handle the error
                                                                        } else {
                                                                            // process successful response
                                                                        }
                                                                }
 client.add(operation: putAttachment)
 ```
 
 */
public class PutAttachmentOperation: CouchDatabaseOperation, JSONOperation {
    
    /**
     Creates the operation.
     
     - parameter name: The name of the attachment to upload.
     - parameter contentType: The content type of the attachment e.g. text/plain.
     - parameter data: The attachment's data.
     - parameter documentID: the ID of the document to attach the attachment to.
     - parameter revision: the revision of the document to attach the attachment to.
     - parameter databaseName: The name of the database that the document is stored in.
     - parameter completionHandler: optional handler to run when the operation completes.
     */
    public init(name: String, contentType: String, data: Data, documentID: String, revision: String, databaseName: String, completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
    
        self.name = name
        self.documentID = documentID
        self.revision = revision
        self.databaseName = databaseName
        self.contentType = contentType
        self.data = data
        self.completionHandler = completionHandler
        
    }
    
    public let databaseName: String
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    
    /**
     The id of the document that the attachment should be attached to.
     
     */
    public let documentID: String
    
    /**
     The revision of the document that the attachment should be attached to.
    */
    public let revision: String
    
    /**
     The name of the attachment.
     */
    public let name: String
    
    /**
     The attachment's data.
    */
    public let data: Data?
    
    /**
     The Content type for the attachment such as text/plain, image/jpeg
     */
    public let contentType: String
    
    public var method: String {
        return "PUT"
    }
    
    public var endpoint: String {
        return "/\(self.databaseName)/\(documentID)/\(name)"
    }
    
    public var parameters: [String: String] {
        return ["rev": revision]
    }
    
}
