//
//  CreateDatabaseOperation.swift
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


public class CreateDatabaseOperation : CouchOperation {
    
    public var databaseName:String? = nil
    
    override public var httpMethod:String {
        get {
            return "PUT"
        }
    }
    
    public override var httpPath:String {
        get {
            // Safe to foce unwrap validation would fail if this is nil
            return "/\(self.databaseName!)"
        }
    }
    
    public var createDatabaseCompletionBlock : ((statusCode:Int?, operationError:ErrorType?) -> Void)? = nil
    
    
    public override func validate() -> Bool {
        return super.validate() && self.databaseName != nil // should work iirc
    }
    
    override public func callCompletionHandler(error: ErrorType) {
        self.createDatabaseCompletionBlock?(statusCode: nil, operationError: error)
    }
    
    public override func processResponse(data: NSData?, statusCode: Int, error: ErrorType?) {
        guard error == nil
        else  {
            self.callCompletionHandler(error!)
            return
        }
        
        if statusCode == 201 || statusCode ==  202 {
            /// success!
            self.createDatabaseCompletionBlock?(statusCode: statusCode, operationError: nil)
        } else {
            callCompletionHandler(Errors.CreateDatabaseFailed)
        }
    }

}