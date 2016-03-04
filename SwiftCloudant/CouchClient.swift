//
//  CouchClient.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation


public class CouchDBClient {
    
    private let username:String? = nil
    private let password:String? = nil
    private let rootURL:NSURL
    public let session:InterceptableSession
    private let queue:NSOperationQueue
    
    
    init(url:NSURL, username:String?, password:String?){
        self.rootURL = url
        session = InterceptableSession()
        queue = NSOperationQueue()
    }
    
    
    func addOperation(operation:CouchOperation){
        operation.mSession = self.session
        operation.rootURL = self.rootURL
        queue.addOperation(operation)
    }
    
    subscript(dbName:String) -> Database {
        return Database(client: self, dbName: dbName)
    }
    
    
    
}