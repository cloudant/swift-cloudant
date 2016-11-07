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
 
 Usage example:
 
 ```
 let deleteDB = DeleteDatabaseOperation(name: "exampleDB") { (response, httpInfo, error) in 
 
    if let error = error {
        // handle the error
    } else {
        // check the response code to determine if the operaton was successful.
    }
 }
 */
public class DeleteDatabaseOperation: CouchOperation, JSONOperation {

    /**
     Creates the operation
     
     - parameter name: the name of the database to delete.
     - completionHandler: optional handler to reun when the operation completes.
     */
    public init(name: String, completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.name = name;
        self.completionHandler = completionHandler
    }
    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    
    /**
     The name of the database to delete.
     */
    public let name: String

     public var method: String {
        get {
            return "DELETE"
        }
    }

     public var endpoint: String {
        get {
            return "/\(self.name)"
        }
    }

}
