//
//  Database.swift
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

public class Database  {
    
    public let name:String
    private let client:CouchDBClient
    
    public init(client:CouchDBClient, dbName:String){
        name = dbName
        self.client = client
    }
    

    public func add(operation:CouchDatabaseOperation){
        operation.databaseName = self.name
        self.client.addOperation(operation)
    }
    
    
    public subscript(key:String) -> Dictionary<String,AnyObject>?{
        let getDocument = GetDocumentOperation()
        getDocument.docId = key
        
        
        var doc:[String:AnyObject]?
        getDocument.getDocumentCompletionBlock = { (document, error ) in
            doc = document
        };
        
        self.add(getDocument)
        getDocument.waitUntilFinished()
        
        return doc
    }
    
    
    
}