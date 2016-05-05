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
    
    public override func processResponse(data: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?) {
        guard error != nil, let httpInfo = httpInfo
        else {
            callCompletionHandler(error:error!)
            return
        }
        
        do {
            if let data = data {
                let json = try NSJSONSerialization.jsonObject(with: data) as! [String: AnyObject]
                // Check status code
                if httpInfo.statusCode == 201 || httpInfo.statusCode == 202 {
                      putDocumentCompletionHandler?(response: json, httpInfo: httpInfo, error: nil)
                } else {
                    putDocumentCompletionHandler?(response: json, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: String(data:data, encoding: NSUTF8StringEncoding)))
                }
                
            } else {
              self.putDocumentCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: nil))
            }
        } catch {
            let response:String?
            if let data = data {
                response = String(data:data, encoding: NSUTF8StringEncoding)
            } else {
                response = nil
            }
            self.putDocumentCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.UnexpectedJSONFormat(statusCode: httpInfo.statusCode, response: response))
        }

    }
}
