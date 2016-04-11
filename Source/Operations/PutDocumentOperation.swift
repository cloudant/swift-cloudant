//
//  PutDocumentOperation.swift
//  ObjectiveCloudant
//
//  Created by stefan kruger on 05/03/2016.
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

public class PutDocumentOperation: CouchDatabaseOperation {
    /**
    The document that this operation will modify.
    
    Must be set before a call can be successfully made.
    */
    public var docId: String? = nil
    
    /**
    If updating a document, set this value to the current revision ID.
    */
    public var revId: String? = nil
    
    /** Body of document. Must be serialisable with NSJSONSerialization */
    public var body: [String:AnyObject]? = nil

    /**
    Completion block to run when the operation completes.
    
    - docId - the id of the document written to the database
    - revId - the revision of the document written to the database
    - statusCode - the HTTP status code
    - operationError - a pointer to an error object containing
    information about an error executing the operation
    */    
    var putDocumentCompletionBlock: ((String?, String?, Int, ErrorType?) -> ())? = nil
    
    public override func validate() -> Bool {
        return super.validate() && docId != nil && body != nil && NSJSONSerialization.isValidJSONObject(body!)
    }
    
    public override var httpMethod: String {
        return "PUT"
    }
    
    public override var httpRequestBody: NSData? {
        get {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions())
                return data
            } catch {
                return nil
            }
        }
    }
    
    public override var httpPath: String {
        return "/\(self.databaseName!)/\(docId!)"
    }
    
    public override var queryItems: [NSURLQueryItem] {
        get {
            var items: [NSURLQueryItem] = []
            
            if let revId = revId {
                items.append(NSURLQueryItem(name: "rev", value: "\(revId)"))
            }
            
            return items
        }
    }
    
    public override func callCompletionHandler(error: ErrorType) {
        putDocumentCompletionBlock?(nil, nil, 0, error)
    }
    
    public override func processResponse(responseData: NSData?, statusCode: Int, error: ErrorType?) {
        if let error = error {
            callCompletionHandler(error)
            return
        }
        
        // Check status code
        if statusCode == 201 || statusCode == 202 {
            guard let responseData = responseData else {
                return
            }
            
            do {
                // Convert the response to JSON. 
                let json = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions())
                if let jsonDict = json as? [String:AnyObject] {
                    putDocumentCompletionBlock?(jsonDict["id"] as? String, jsonDict["rev"] as? String, statusCode, nil)
                } else {
                    callCompletionHandler(Errors.UnexpectedJSONFormat)
                }
            } catch {
                callCompletionHandler(error)
            }
        } else {
            callCompletionHandler(Errors.CreateUpdateDocumentFailed)
        }
    }
}
