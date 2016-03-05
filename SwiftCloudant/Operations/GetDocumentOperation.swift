//
//  GetDocumentOperation.swift
//  ObjectiveCloudant
//
//  Created by Stefan Kruger on 04/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation

class GetDocumentOperation: CouchDatabaseOperation {

    // Set to true to return revision information (revs=true)
    var revs: Bool? = nil
    
    /**
    *  The revision at which you want the document.
    *
    *  Optional: If omitted CouchDB will return the
    *  document it determines is the current winning revision
    */
    var revId: String? = nil
    
    /**
    *  The document that this operation will access or modify.
    *
    *  Must be set before a call can be successfully made.
    */
    var docId: String? = nil
    
    /**
    *  Completion block to run when the operation completes.
    *
    *  - document - The document read from the server
    *
    * - operationError - a pointer to an error object containing
    *   information about an error executing the operation
    */
    var getDocumentCompletionBlock: (([String:AnyObject]?, ErrorType?) -> ())?

    override func validate() -> Bool {
        return super.validate() && docId != nil
    }
    
    override var httpMethod: String {
        return "GET"
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
            
            if let revs = revs {
                items.append(NSURLQueryItem(name: "revs", value: "\(revs)"))
            }
            
            return items
        }
    }
    
    override func callCompletionHandler(error: ErrorType) {
        self.getDocumentCompletionBlock?(nil, error)
    }
    
    override func processResponse(responseData: NSData?, statusCode: Int, error: ErrorType?) {
        if let error = error {
            callCompletionHandler(error)
            return
        }
        
        // Check status code is 200
        if statusCode == 200 {
            guard let responseData = responseData else {
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions())
                getDocumentCompletionBlock?(json as? [String:AnyObject], nil)
            } catch {
                callCompletionHandler(error)
            }
        } else {
            callCompletionHandler(Errors.GetDocumentFailed)
        }
    }
}
