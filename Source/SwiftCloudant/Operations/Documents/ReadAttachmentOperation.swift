//
//  ReadAttachmentOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 02/06/2016.
//  Copyright © 2016 IBM. All rights reserved.
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
 An Operation to read an attachment from the database
 
 - Requires: All properties defined on this operation to be set.
 
 Example usage:
 
 ```
 let read = ReadAttachmentOperation(name: attachmentName, documentID: docID, databaseName: dbName){ (data, info, error) in
    if let error = error {
        // handle the error
    } else {
        // process the successful response
    }
 }
 client.add(operation:read)
 ```
 */
 
public class ReadAttachmentOperation: CouchDatabaseOperation, DataOperation {
    
    /**
     Creates the operation.
     
     - parameter name: the name of the attachment to read from the server
     - parameter documentID: the ID of the document that the attachment is attached to 
     - parameter revision: the revision of the document that the attachment is attached to, or `nil` for latest.
     - parameter databaseName: the name of the database that the attachment is stored in.
     - parameter completionHAndler: optional handler to run when the operation completes.
     */
    public init(name: String, documentID: String, revision: String? = nil, databaseName: String, completionHandler: ((Data?, HTTPInfo?, Error?) -> Void)? = nil) {
    
        self.name = name
        self.documentID = documentID
        self.revision = revision
        self.databaseName = databaseName
        self.completionHandler = completionHandler
    }
    
    /**
     Sets a completion handler to run when the operation completes.
     
     - parameter data: - The attachment data.
     - parameter httpInfo: - Information about the HTTP response.
     - parameter error: - ErrorProtocol instance with information about an error executing the operation.
     */
    public let completionHandler: ((Data?, HTTPInfo?, Error?) -> Void)?
    
    public let databaseName: String
    
    /**
     The id of the document that the attachment should be attached to.
     */
    public let documentID: String
    
    /**
     The revision of the document that the attachment should be attached to.
     */
    public let revision: String?
    
    /**
     The name of the attachment.
     */
    public let name: String
    
    public var method: String {
        return "GET"
    }
    
    public var endpoint: String {
        return "/\(self.databaseName)/\(documentID)/\(name)"
    }
    
    public var parameters: [String: String] {
        
        if let revision = self.revision {
            return ["rev": revision]
        } else {
            return [:]
        }
    }
    
    
    
}
