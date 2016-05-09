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
 
        let delete = DeleteDocumentOperation()
        delete.docId = "exampleDocId"
        delete.revId = "1-examplerevid"
        delete.deleteDocumentCompletionBlock = { (statusCode,error) in 
                if let error = error {
                    NSLog("An error occured attemtping to delete a document")
                } else {
                    NSLog("Document deleted with statusCode \(statusCode!)"
                }
            }
        database.add(delete)
 
 */
public class DeleteDocumentOperation : CouchDatabaseOperation {
    
    /**
     * The revision of the document to delete
     *
     * **Must** be set before an operation can succesfully execute.
     */
    public var revId:String? = nil
    
    /**
     * The id of the document to delete.
     *
     * **Must** be set before an operation can succesfully execute.
     */
    public var docId:String? = nil
    
    public override func validate() -> Bool {
        return super.validate() && revId != nil && docId != nil
    }
    
    public override var httpMethod: String {
        return "DELETE"
    }
    
    public override var httpPath: String {
        return "/\(self.databaseName!)/\(docId!)"
    }
    
    public override var queryItems: [NSURLQueryItem] {
       return [NSURLQueryItem(name: "rev", value: revId!)]
    }
    
    public override func callCompletionHandler(error: ErrorProtocol) {
        self.completionHandler?(response: nil, httpInfo: nil, error: error)
    }
    
    public override func processResponse(data: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?) {
        guard error == nil, let httpInfo = httpInfo
            else {
                self.callCompletionHandler(error: error!)
                return;
        }
        
        
        do {
            
            if let data = data {
                let json = try NSJSONSerialization.jsonObject(with: data) as! [String:AnyObject]
                
                if httpInfo.statusCode / 100 == 2 {
                    self.completionHandler?(response: json, httpInfo: httpInfo, error: nil)
                } else {
                    self.completionHandler?(response: json, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: String(data:data, encoding: NSUTF8StringEncoding)))
                }
            } else {
                self.completionHandler?(response: nil, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: nil))
            }
            
        } catch {
            let response:String?
            if let data = data {
                response = String(data:data, encoding: NSUTF8StringEncoding)
            } else {
                response = nil
            }
            self.completionHandler?(response: nil, httpInfo: httpInfo, error: Errors.UnexpectedJSONFormat(statusCode: httpInfo.statusCode, response: response))
        }
    }
}
