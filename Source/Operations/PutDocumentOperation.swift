//
//  PutDocumentOperation.swift
//  ObjectiveCloudant
//
//  Created by stefan kruger on 05/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation

class PutDocumentOperation: CouchDatabaseOperation {
    /**
    The document that this operation will modify.
    
    Must be set before a call can be successfully made.
    */
    var docId: String? = nil
    
    /**
    If updating a document, set this value to the current revision ID.
    */
    var revId: String? = nil
    
    /** Body of document. Must be serialisable with NSJSONSerialization */
    var body: AnyObject? = nil

    /**
    Completion block to run when the operation completes.
    
    - docId - the id of the document written to the database
    - revId - the revision of the document written to the database
    - statusCode - the HTTP status code
    - operationError - a pointer to an error object containing
    information about an error executing the operation
    */    
    var putDocumentCompletionBlock: ((String?, String?, Int, ErrorType?) -> ())? = nil
    
    override func validate() -> Bool {
        return super.validate() && docId != nil && body != nil && NSJSONSerialization.isValidJSONObject(body!)
    }
    
    override var httpMethod: String {
        return "PUT"
    }
    
    override var httpRequestBody: NSData? {
        get {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions())
                return data
            } catch {
                return nil
            }
        }
    }
    
    override var httpPath: String {
        return "/\(self.databaseName!)/\(docId!)"
    }
    
    override var queryItems: [NSURLQueryItem] {
        get {
            var items: [NSURLQueryItem] = []
            
            if let revId = revId {
                items.append(NSURLQueryItem(name: "rev", value: "\(revId)"))
            }
            
            return items
        }
    }
    
    override func callCompletionHandler(error: ErrorType) {
        putDocumentCompletionBlock?(nil, nil, 0, error)
    }
    
    override func processResponse(responseData: NSData?, statusCode: Int, error: ErrorType?) {
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
