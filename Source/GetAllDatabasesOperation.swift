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
 let allDbs = GetAllDatabasesOperation()
 allDbs.databaseHandler = { (databaseName) in 
    // do something for the database name
 }
 allDbs.completionHandler = { (response, httpInfo, error) in 
    if let error = error {
        // handle the error case
    }
    // process the response information
 }
 
 - Note: The `response` parameter for the `completionHandler` **will not** match the response
  received from Couch. This is because CouchDB returns an array as a top level object and the
  completion handler only accepts Dictionaries. To access the list of database names, use the key
  `databases`
 
 */
public class GetAllDatabasesOperation : CouchOperation {
    
    /**
        Handler to run for each database returned.
     
        - parameter databaseName: the name of a database on the server.
     */
    public var databaseHandler: ((databaseName: String) -> Void)?
    
    override public var httpPath: String {
        return "/_all_dbs"
    }
    
    
    override public func processResponse(data: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?) {
        guard error == nil, let httpInfo = httpInfo
            else {
                self.callCompletionHandler(error: error!)
                return
        }
        
        do {
            if let data = data {
                let json = try NSJSONSerialization.jsonObject(with: data)
                if httpInfo.statusCode / 100 == 2 {
                    
                    if let json = json as? [String] {
                        for dbName in json {
                            self.databaseHandler?(databaseName: dbName)
                        }
                        // we need to wrap the response, because if it is sucessful it returns an array not a dict
                        self.completionHandler?(response: ["databases":json as NSArray], httpInfo: httpInfo, error: nil)
                    }

                } else {
                    self.completionHandler?(response: json as? [String : AnyObject], httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: String(data: data, encoding: NSUTF8StringEncoding)))
                }
            } else {
                self.completionHandler?(response: nil, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: nil))
            }
        } catch {
            let response: String?
            if let data = data {
                response = String(data: data, encoding: NSUTF8StringEncoding)
            } else {
                response = nil
            }
            self.completionHandler?(response: nil, httpInfo: httpInfo, error: Errors.UnexpectedJSONFormat(statusCode: httpInfo.statusCode, response: response))
        }
    }
    
    
}