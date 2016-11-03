//
//  GetAllDatabasesOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 23/05/2016.
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
 
 An operation to get **all** the databases on a server.
 
 Example usage:
 ```
 let allDbs = GetAllDatabasesOperation(
    databaseHandler: { (databaseName) in
    // do something for the database name
 }) { (response, httpInfo, error) in
    if let error = error {
        // handle the error case
    }
    // process the response information
 }
 
 */
public class GetAllDatabasesOperation : CouchOperation, JSONOperation {
    public typealias Json = [Any]

    
    /**
     
     Creates the operation
     
     - parameter databaseHandler: optional handler to call for each database returned from the server.
     - parameter completionHander: optional handler to call when the operation completes.
     */
    public init(databaseHandler: ((_ databaseName: String) -> Void)? = nil,
        completionHandler:(([Any]?, HTTPInfo?,Error?) -> Void)? = nil) {
    
        self.databaseHandler = databaseHandler
        self.completionHandler = completionHandler
    }
    
    /**
        Handler to run for each database returned.
     
        - parameter databaseName: the name of a database on the server.
     */
    public let databaseHandler: ((_ databaseName: String) -> Void)?
    
    public let completionHandler: (([Any]?, HTTPInfo?, Error?) -> Void)?
    
    public var endpoint: String {
        return "/_all_dbs"
    }
    
    public func validate() -> Bool {
        return true
    }
    
    public func processResponse(json: Any) {
        if let json = json as? [String] {
            for dbName in json {
                self.databaseHandler?(dbName)
            }
        }
    }
    
}
