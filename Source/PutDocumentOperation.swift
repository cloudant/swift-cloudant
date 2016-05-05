//
//  PutDocumentOperation.swift
//  SwiftCloudant
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
    
     - parameter response: - The full deseralised JSON response.
     - parameter httpInfo: - Information about the HTTP response.
     - parameter error: - a pointer to an error object containing
     information about an error executing the operation
    */
    var putDocumentCompletionHandler: ((response:[String:AnyObject]?, httpInfo: HttpInfo?, error:ErrorProtocol?)-> Void)? = nil
    
    public override func validate() -> Bool {
        return super.validate() && docId != nil && body != nil && NSJSONSerialization.isValidJSONObject(body!)
    }
    
    public override var httpMethod: String {
        return "PUT"
    }
    
    public override var httpRequestBody: NSData? {
        get {
            do {
                let data = try NSJSONSerialization.data(withJSONObject:body!, options: NSJSONWritingOptions())
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
    
    public override func callCompletionHandler(error: ErrorProtocol) {
        putDocumentCompletionHandler?(response: nil, httpInfo: nil, error: error)
    }
    
    public override func processResponse(data: NSData?, statusCode: Int, error: ErrorProtocol?) {
        if let error = error {
            callCompletionHandler(error:error)
            return
        }
        
        let httpInfo = HttpInfo(statusCode: statusCode, headers: [:])
        
        // Check status code
        if statusCode == 201 || statusCode == 202 {
            guard let data = data else {
                return
            }
            
            do {
                // Convert the response to JSON.
                let json = try NSJSONSerialization.jsonObject(with:data, options: NSJSONReadingOptions())
                if let jsonDict = json as? [String:AnyObject] {
                    putDocumentCompletionHandler?(response: jsonDict, httpInfo: httpInfo, error: error)
                } else {
                    callCompletionHandler(error: Errors.UnexpectedJSONFormat(statusCode: statusCode, response: String(data: data, encoding: NSUTF8StringEncoding)))
                }
            } catch {
                callCompletionHandler(error:error)
            }
        } else {
            guard let data = data else {
                putDocumentCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.HTTP(statusCode: statusCode, response: nil))
                return
            }
            
            
            putDocumentCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.HTTP(statusCode: statusCode,
                                                                                          response: String(data: data, encoding: NSUTF8StringEncoding)))
        }
    }
}
