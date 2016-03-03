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
    public let session:InterceptableSession
    
    
    init(url:NSURL, username:String?, password:String?){
        session = InterceptableSession()
    }
    
    
    func addOperation(operation:NSOperation){
        
    }
    
    subscript(dbName:String) -> Database {
        return Database(client: self, dbName: dbName)
    }
    
    
    
}