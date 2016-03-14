//
//  GetDocumentTests.swift
//  ObjectiveCloudant
//
//  Created by Stefan Kruger on 04/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCloudant

class GetDocumentTests : XCTestCase {
    let url = "http://localhost:5984"
    let username: String? = nil
    let password: String? = nil
    var dbName: String? = nil
    
    func createTestDocuments(count: Int) -> [[String:AnyObject]] {
        var docs = [[String:AnyObject]]()
        for _ in 1...count {
            docs.append(["data": NSUUID().UUIDString.lowercaseString])
        }
        
        return docs
    }
    
    override func setUp() {
        super.setUp()
         
        dbName = NSUUID().UUIDString.lowercaseString
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let create = CreateDatabaseOperation()
        create.databaseName = dbName!
        client.addOperation(create)
        create.waitUntilFinished()
        
        print("Created database: \(dbName!)")
    }
    
//    override func tearDown() {
//        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
//        let delete = DeleteDatabaseOperation()
//        delete.databaseName = dbName!
//        client.addOperation(delete)
//        delete.waitUntilFinished()
//        
//        super.tearDown()
//        
//        print("Deleted database: \(dbName!)")
//    }
    
    func testPutDocument() {
        let data = createTestDocuments(1)
        
        let putDocumentExpectation = expectationWithDescription("put document")
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        
        let put = PutDocumentOperation()
        put.databaseName = dbName
        put.body = data[0]
        put.docId = NSUUID().UUIDString.lowercaseString
        
        put.putDocumentCompletionBlock = { (docId, revId, statusCode, error) in
            putDocumentExpectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(docId)
            XCTAssertNotNil(revId)
            XCTAssert(statusCode == 201 || statusCode == 202)
        }
        
        client.addOperation(put)
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testGetDocument() {
        let data = createTestDocuments(1)
        let getDocumentExpectation = expectationWithDescription("get document")
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        
        let put = PutDocumentOperation()
        put.databaseName = dbName
        put.body = data[0]
        put.docId = NSUUID().UUIDString.lowercaseString
        client.addOperation(put)
        put.waitUntilFinished()
        
        let get = GetDocumentOperation()
        get.databaseName = dbName
        get.docId = put.docId
        
        get.getDocumentCompletionBlock = { (doc, error) in
            getDocumentExpectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(doc)
        }
        
        client.addOperation(get)
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
}