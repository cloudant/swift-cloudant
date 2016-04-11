//
//  CouchClient.swift
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


public class CouchDBClient {
    
    private let username:String? = nil
    private let password:String? = nil
    private let rootURL:NSURL
    private let session:InterceptableSession
    private let queue:NSOperationQueue
    
    
    public init(url:NSURL, username:String?, password:String?){
        self.rootURL = url
        session = InterceptableSession()
        queue = NSOperationQueue()
    }
    
    
    public func addOperation(operation:CouchOperation){
        operation.mSession = self.session
        operation.rootURL = self.rootURL
        queue.addOperation(operation)
    }
    
    public subscript(dbName:String) -> Database {
        return Database(client: self, dbName: dbName)
    }
    
    
    
}