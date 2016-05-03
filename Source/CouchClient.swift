//
//  CouchClient.swift
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
    Class for running operations against a CouchDB instance.
 */
public class CouchDBClient {
    
    private let username:String?
    private let password:String?
    private let rootURL:NSURL
    private let session:InterceptableSession
    private let queue:NSOperationQueue
    
    /**
     Creates a CouchDBClient instance.
     
     - parameter url: url of the server to connect to.
     - parameter username: the username to use when authenticating.
     - parameter password: the password to use when authenticating.
     */
    public init(url:NSURL, username:String?, password:String?){
        self.rootURL = url
        self.username = username
        self.password = password
        queue = NSOperationQueue()
        let interceptors: [HTTPInterceptor]
        
        if let username = username, let password = password {
            let cookieInterceptor = SessionCookieInterceptor(username: username, password: password)
            interceptors = [cookieInterceptor]
        } else {
            interceptors = []
        }
        
        self.session = InterceptableSession(delegate: nil, requestInterceptors: interceptors)

    }
    
    /**
        Adds an operation to the queue to be executed.
        - parameter operation: the operation to add to the queue.
     */
    public func add(operation:CouchOperation){
        operation.mSession = self.session
        operation.rootURL = self.rootURL
        queue.addOperation(operation)
    }
    
    /**
      Creates a database object.
     - parameter dbName: the name of the database the object should represent.
     - returns: A new `Database` object representing a CouchDB Database.
     */
    public subscript(dbName:String) -> Database {
        return Database(client: self, dbName: dbName)
    }
    
    
    
}