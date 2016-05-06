//
//  DeleteDatabaseOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 03/03/2016.
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
 Deletes a database from a CouchDB instance
 */
public class DeleteDatabaseOperation : CouchOperation {
    
    /**
        The name of the database to delete.
     
        This must be set before an operation can complete sucessfully
     */
    public var databaseName:String? = nil
    
    override public var httpMethod:String {
        get {
            return "DELETE"
        }
    }
    
    override public var httpPath:String {
        get {
            // Safe to foce unwrap validation would fail if this is nil
            return "/\(self.databaseName!)"
        }
    }
    
    /**
        A block to call when the operation completes.
     - parameter response: The full JSON response.
     - parameter httpInfo: Information about the HTTP response.
     - parameter error: An Error that occured.
     */
    public var deleteDatabaseCompletionHandler: ((response:[String:AnyObject]?, httpInfo: HttpInfo?, error:ErrorProtocol?)-> Void)? = nil
    
    
    public override func validate() -> Bool {
        return super.validate() && self.databaseName != nil // should work iirc
    }
    
    public override func callCompletionHandler(error: ErrorProtocol) {
        self.deleteDatabaseCompletionHandler?(response: nil, httpInfo: nil, error: error)
    }
    
    public override func processResponse(data: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?) {
        guard error == nil, let httpInfo = httpInfo
            else  {
                self.callCompletionHandler(error: error!)
                return
        }
        
        do {
            if let data = data {
                let json = try NSJSONSerialization.jsonObject(with: data) as! [String: AnyObject]
                
                if httpInfo.statusCode == 200 || httpInfo.statusCode ==  202 { //Couch could return accepted instead of ok.
                    /// success!
                    self.deleteDatabaseCompletionHandler?(response:json, httpInfo: httpInfo, error: nil)
                } else {
                    let response = String(data: data, encoding: NSUTF8StringEncoding)
                    self.deleteDatabaseCompletionHandler?(response:json, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: response))
                }
                
            } else {
                self.deleteDatabaseCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.UnexpectedJSONFormat(statusCode: httpInfo.statusCode, response: nil))
            }
        } catch {
            let response:String?
            if let data = data {
                response = String(data:data, encoding: NSUTF8StringEncoding)
            } else {
                response = nil
            }
            self.deleteDatabaseCompletionHandler?(response: nil, httpInfo: httpInfo, error: Errors.UnexpectedJSONFormat(statusCode: httpInfo.statusCode, response: response))
        }
        
        

    }
    
}