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
    
    /**
     * A block of code to call when the operation completes.
     * This block will be called once per operation.
     *
     * statusCode: The status code returned from the request, will be nil if the operation
     *                       did not make an http connection.
     *
     * error: An object representing the error that occured, will be nil when the operation
     *                  successfully makes a HTTP request.
     */
    public var deleteDocumentCompletionBlock : ((statusCode:Int?, error:ErrorType?) ->())? = nil
    
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
    
    public override func callCompletionHandler(error: ErrorType) {
        self.deleteDocumentCompletionBlock?(statusCode: nil,error: error)
    }
    
    public override func processResponse(data: NSData?, statusCode: Int, error: ErrorType?) {
        if let error = error {
            callCompletionHandler(error)
        } else {
            deleteDocumentCompletionBlock?(statusCode: statusCode,error: error);
        }
    }
}