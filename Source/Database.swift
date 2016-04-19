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

/**
 A class representing a CouchDB Database.
 */
public class Database  {
    
    /**
     The name of the database
     */
    public let name:String
    private let client:CouchDBClient
    
    /**
        Creates a Database object to represent a CouchDB database
        - parameter client: An instance of `CouchDBClient`
        - parameter dbName: The name of the database to represent.
    */
    public init(client:CouchDBClient, dbName:String){
        name = dbName
        self.client = client
    }
    
    /**
        Add an operation to the queue to be executed.
        
        This performs the equivalent of
            
            let databaseOperation = PutDocumentOperation()
            // ...
            databaseOperation.databaseName = "exampleDB"
            client.addOperation(operation:databaseOperation)
     */
    public func add(operation:CouchDatabaseOperation){
        operation.databaseName = self.name
        self.client.add(operation: operation)
    }
    
    /**
        Provides a synchronous way of retrieving a document from the database represented by
        this object.
     
        - parameter key: The id of the document to retrieve.
        - returns: The document as a `Dictionary` or `nil` if the document was not found or 
            an error occured.
    */
    public subscript(key:String) -> Dictionary<String,AnyObject>?{
        let getDocument = GetDocumentOperation()
        getDocument.docId = key
        
        
        var doc:[String:AnyObject]?
        getDocument.getDocumentCompletionHandler = { (document, error ) in
            doc = document
        };
        
        self.add(operation: getDocument)
        getDocument.waitUntilFinished()
        
        return doc
    }
    
    
    
}