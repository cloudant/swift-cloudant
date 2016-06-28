//
//  CreateDatabaseOperation.swift
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
 An operation to create a database in a CouchDB instance.
 */
public class CreateDatabaseOperation: CouchOperation, JsonOperation {

    public init() { }
    
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: ErrorProtocol?) -> Void)?
    
    /**
     The name of the database to create.

     This is required to be set before the operation can execute succesfully.
     */
    public var databaseName: String?

     public var method: String {
        get {
            return "PUT"
        }
    }

    public var endpoint: String {
        get {
            // Safe to force unwrap, validation would fail if this is nil
            return "/\(self.databaseName!)"
        }
    }

    public func validate() -> Bool {
        return  self.databaseName != nil
    }

}
