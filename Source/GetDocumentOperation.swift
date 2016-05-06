//
//  GetDocumentOperation.swift
//  SwiftCloudant
//
//  Created by Stefan Kruger on 04/03/2016.
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

public class GetDocumentOperation: CouchDatabaseOperation {

    /**
        Include all revisions of the document.
        `true` to include revisions, `false` to not include revisions, leave as `nil` to not emit
        into the json.
     */
    public var revs: Bool? = nil
    
    /**
      The revision at which you want the document.
    
      Optional: If omitted CouchDB will return the
      document it determines is the current winning revision
    */
    public var revId: String? = nil
    
    /**
      The document that this operation will access or modify.
    
      Must be set before a call can be successfully made.
    */
    public var docId: String? = nil
    
    /**
      Completion block to run when the operation completes.
    
      - parameter response: - The full deseralised JSON response.
      - parameter httpInfo: - Information about the HTTP response.
      - parameter error: - a pointer to an error object containing
       information about an error executing the operation
    */
    public var getDocumentCompletionHandler: ((response:[String:AnyObject]?, httpInfo: HttpInfo?, error:ErrorProtocol?)-> Void)?

    public override func validate() -> Bool {
        return super.validate() && docId != nil
    }
    
    public override var httpMethod: String {
        return "GET"
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
            
            if let revs = revs {
                items.append(NSURLQueryItem(name: "revs", value: "\(revs)"))
            }
            
            return items
        }
    }
    
    public override func callCompletionHandler(error: ErrorProtocol) {
        self.getDocumentCompletionHandler?(response:nil, httpInfo: nil ,error: error)
    }
    
    public override func processResponse(data: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?) {
        guard error == nil, let httpInfo = httpInfo
        else {
            callCompletionHandler(error:error!)
            return
        }
        
        do {
            if let data = data {
                let json = try NSJSONSerialization.jsonObject(with: data) as! [String:AnyObject]
                if httpInfo.statusCode == 200 {
                    self.getDocumentCompletionHandler?(response: json, httpInfo: httpInfo, error: nil)
                } else {
                    self.getDocumentCompletionHandler?(response: json, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: String(data:data, encoding:NSUTF8StringEncoding)))
                }
                
            } else {
                self.getDocumentCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: nil))
            }
        } catch {
            let response:String?
            if let data = data {
                response = String(data:data, encoding: NSUTF8StringEncoding)
            } else {
                response = nil
            }
            
            self.getDocumentCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.UnexpectedJSONFormat(statusCode: httpInfo.statusCode, response: response))
        }
    }
}
