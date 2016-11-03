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
 
 Example usage:
 ```
 let createDB = CreateDatabaseOperation(name: "exampleDB") { (response, info, error) in
     if let error = error {
         // handle the error case
     } else {
        //handle sucessful creation.
     }
 
 }
 client.add(operation: createDB)
 */
public class CreateDatabaseOperation: CouchOperation, JSONOperation {

    /**
     Creates the operation.
     
     - parameter name: The name of the database this operation will create.
     - parameter completionHandler: optional handler to call when the operation completes.
    */
    public init(name: String, completionHandler: ((_ response: [String : Any]?, _ httpInfo: HTTPInfo?, _ error: Error?) -> Void)? = nil) {
        self.name = name
        self.completionHandler = completionHandler
    }
    
    public let completionHandler: ((_ response: [String : Any]?, _ httpInfo: HTTPInfo?, _ error: Error?) -> Void)?
    
    /**
     The name of the database to create.
     */
    public let name: String

     public var method: String {
        get {
            return "PUT"
        }
    }

    public var endpoint: String {
        get {
            return "/\(self.name)"
        }
    }

}
