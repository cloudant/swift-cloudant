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
 
 - Requires: All properties defined on this operation to be set.
 
 Example usage:
 ```
 let attachment = "This is my awesome essay attachment for my document"
 let putAttachment = PutAttachmentOperation()
 putAttachment.docId = docId
 putAttachment.revId = revId
 putAttachment.data = attachment.data(using: NSUTF8StringEncoding, allowLossyConversion: false)
 putAttachment.attachmentName = "myAwesomeAttachment"
 putAttachment.contentType = "text/plain"
 putAttachment.completionHandler = {(response, info, error) in
    if let error = error {
        // handle the error
    } else {
        // process successful response
    }
 }
 database.add(operation: putAttachment)
 ```
 
 */
public class PutAttachmentOperation: AttachmentOperation {
    
    /**
     The attachment's data.
    */
    public var data: NSData?
    
    /**
     The Content type for the attachment such as text/plain, image/jpeg
     */
    public var contentType: String?
    
    
    public override func validate() -> Bool {
        if !super.validate() {
            return false
        }
        
        if data == nil {
            return false
        }
        
        if contentType == nil {
            return false
        }
        
        return true
    }
    
    public override var httpMethod: String {
        return "PUT"
    }
    
    public override var httpRequestBody: NSData? {
        return data
    }
    
    public override var httpContentType: String {
        return contentType!
    }
    
}
