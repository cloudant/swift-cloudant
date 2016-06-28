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
 let read = ReadAttachmentOperation()
 read.docId = docId
 read.revId = revId
 read.attachmentName = attachmentName
 read.databaseName = dbName
 read.readAttachmentCompletionHandler = {(data, info, error) in 
    if let error = error {
        // handle the error
    } else {
        // process the successful response
    }
 }
 database.add(operation:read)
 ```
 */
 
public class ReadAttachmentOperation: CouchDatabaseOperation, DataOperation {
    
    public init() { }
    
    /**
     Sets a completion handler to run when the operation completes.
     
     - parameter data: - The attachment data.
     - parameter httpInfo: - Information about the HTTP response.
     - parameter error: - ErrorProtocol instance with information about an error executing the operation.
     */
    public var completionHandler: ((response: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?) -> Void)?
    
    public var databaseName: String?
    
    /**
     The id of the document that the attachment should be attached to.
     */
    public var docId: String?
    
    /**
     The revision of the document that the attachment should be attached to.
     */
    public var revId: String?
    
    /**
     The name of the attachment.
     */
    public var attachmentName: String?
    
    public func validate() -> Bool {
        if self.databaseName == nil {
            return false
        }
        if docId == nil {
            return false
        }
        
        if revId == nil {
            return false
        }
        
        if attachmentName == nil {
            return false
        }
        
        return true
    }
    
    public var method: String {
        return "GET"
    }
    
    public var endpoint: String {
        return "/\(self.databaseName!)/\(docId!)/\(attachmentName!)"
    }
    
    public var parameters: [String: String] {
        return ["rev": revId!]
    }
    
    
    
}