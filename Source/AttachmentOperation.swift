//
//  AttachmentOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 23/05/2016.
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
 - warning: This class is **not** to be used directly, it only acts as a base for attachment operations
 */
public class AttachmentOperation: CouchDatabaseOperation {
    
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
    
    public override func validate() -> Bool {
        if !super.validate() {
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
    
    public override var httpPath: String {
        return "/\(self.databaseName!)/\(docId!)/\(attachmentName!)"
    }
    
    public override var queryItems: [NSURLQueryItem] {
        return [NSURLQueryItem(name: "rev", value: revId)]
    }
    
    public override var httpMethod: String {
        return "HEAD"
    }
    
    
}
