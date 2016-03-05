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
//    let url = "http://localhost:5984"
//    let username: String? = nil
//    let password: String? = nil
//    let dbName = NSUUID().UUIDString.lowercaseString
    
    let url = "https://skruger.cloudant.com"
    let username: String? = "XXX"
    let password: String? = "YYY"
    let dbName = "swiftdb"
    
//    override func setUp() {
//        super.setUp()
//        
//        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
//        let create = CreateDatabaseOperation(httpSession: client.session)
//        create.databaseName = dbName
//        client.addOperation(create)
//        create.waitUntilFinished()
//    }
//    
//    override func tearDown() {
//        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
//        let delete = DeleteDatabaseOperation(httpSession: client.session)
//        delete.databaseName = dbName
//        client.addOperation(delete)
//        delete.waitUntilFinished()
//        
//        super.tearDown()
//    }
    
    func testGetDocument() {
        let getDocumentExpectation = expectationWithDescription("get document")
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        
        let get = GetDocumentOperation()
        get.databaseName = dbName
        get.docId = "07bb721df13c4e4f3df836fca2f3d95f"
        
        get.getDocumentCompletionBlock = { (doc, error) in
            getDocumentExpectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(doc)
        }
        
        client.addOperation(get)
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
}