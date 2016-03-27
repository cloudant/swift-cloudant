//
//  File.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 26/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCloudant

class PutDocumentTests : XCTestCase {
    let url = "http://localhost:5984"
    let username: String? = nil
    let password: String? = nil
    var client: CouchDBClient? = nil;
    var dbName: String? = nil
    
    override func setUp() {
        super.setUp()
        
        dbName = "a-\(NSUUID().UUIDString.lowercaseString)"
        self.client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let create = CreateDatabaseOperation()
        create.databaseName = dbName!
        client!.addOperation(create)
        create.waitUntilFinished()
        
        print("Created database: \(dbName!)")
    }
    
    
    func testSaveDocument(){
        let db = self.client![self.dbName!]
        let putExpectation = self.expectationWithDescription("Put Document expectation")
        let put = PutDocumentOperation()
        put.docId = "Doc1"
        put.body = ["hello":"world"]
        put.putDocumentCompletionBlock = {(docId,revId,statusCode,error) in
            putExpectation.fulfill()
            XCTAssertNotNil(docId)
            XCTAssertNotNil(revId)
            XCTAssertEqual(2, statusCode / 100)
            XCTAssertEqual("Doc1", docId)
        }
        db.add(put)
        
        self.waitForExpectationsWithTimeout(10) { (_) in
            
        }
        
    }
}