//
//  Database.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation

public class Database  {
    
    public let name:String
    private let client:CouchDBClient
    
    init(client:CouchDBClient, dbName:String){
        name = dbName
        self.client = client
    }
    

    public func add(operation:CouchDatabaseOperation){
        operation.databaseName = self.name
        self.client.addOperation(operation)
    }
    
    
    subscript(key:String) -> Dictionary<String,AnyObject>?{
        return nil
    }
    
    
    
}