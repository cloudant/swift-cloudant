//
//  DeleteDatabaseOperation.swift
//  ObjectiveCloudant
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
     - parameter statusCode: The status code of the HTTP response.
     - parameter operationError: The error that occurred if any.
     */
    public var deleteDatabaseCompletionHandler: ((statusCode:Int?, operationError:ErrorProtocol?) -> Void)? = nil
    
    
    public override func validate() -> Bool {
        return super.validate() && self.databaseName != nil // should work iirc
    }
    
    public override func callCompletionHandler(error: ErrorProtocol) {
        self.deleteDatabaseCompletionHandler?(statusCode: nil, operationError: error)
    }
    
    public override func processResponse(data: NSData?, statusCode: Int, error: ErrorProtocol?) {
        guard error == nil
            else  {
                self.callCompletionHandler(error: error!)
                return
        }
        
        if statusCode == 200 || statusCode ==  202 { //Couch could return accepted instead of ok.
            /// success!
            self.deleteDatabaseCompletionHandler?(statusCode: statusCode, operationError: nil)
        } else {
            let response:String?
            if let data = data {
                response = String(data: data, encoding: NSUTF8StringEncoding)
            } else {
                response = nil
            }
            
            self.deleteDatabaseCompletionHandler?(statusCode: statusCode, operationError:Errors.CreateDatabaseFailed(statusCode: statusCode, jsonResponse: response))
        }
    }
    
}