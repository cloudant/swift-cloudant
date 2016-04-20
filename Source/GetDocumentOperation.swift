//
//  GetDocumentOperation.swift
//  ObjectiveCloudant
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
    
      - parameter document: - The document read from the server
    
      - parameter operationError: - a pointer to an error object containing
       information about an error executing the operation
    */
    public var getDocumentCompletionHandler: ((document:[String:AnyObject]?, operationError:ErrorProtocol?) -> ())?

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
        self.getDocumentCompletionHandler?(document: nil, operationError: error)
    }
    
    public override func processResponse(data: NSData?, statusCode: Int, error: ErrorProtocol?) {
        if let error = error {
            callCompletionHandler(error:error)
            return
        }
        
        // Check status code is 200
        if statusCode == 200 {
            guard let data = data else {
                return
            }
            
            do {
                let json = try NSJSONSerialization.jsonObject(with:data, options: NSJSONReadingOptions())
                getDocumentCompletionHandler?(document: json as? [String:AnyObject], operationError: nil)
            } catch {
                callCompletionHandler(error:error)
            }
        } else {
            callCompletionHandler(error:Errors.GetDocumentFailed)
        }
    }
}
