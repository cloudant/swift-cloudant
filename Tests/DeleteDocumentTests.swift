//
//  DeleteDocumentTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 12/04/2016.
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
import XCTest
@testable import SwiftCloudant

class DeleteDocumentTests : XCTestCase {
    var dbName: String? = nil
    
    override func setUp() {
        super.setUp()
        
        dbName = "a-\(NSUUID().uuidString.lowercased())"
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let create = CreateDatabaseOperation()
        create.databaseName = dbName!
        client.add(operation:create)
        create.waitUntilFinished()
        
        print("Created database: \(dbName!)")
    }
    
    func testDocumentCanBeDeleted() {
        
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let db = client[self.dbName!]
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.deleteDocumentCompletionHandler = {(statusCode, error) in
            expectation.fulfill()
            XCTAssertNotNil(statusCode)
            if let statusCode = statusCode {
                XCTAssert(statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        
        let create = PutDocumentOperation()
        create.docId = "testId"
        create.body = ["hello":"world"]
        create.putDocumentCompletionHandler = {(docId,revId,statusCode,error) in
            delete.revId = revId
            delete.docId = docId
        }
        
        delete.addDependency(create)
        
        db.add(operation: create)
        db.add(operation: delete)
        
        self.waitForExpectations(withTimeout:10.0, handler: nil)
        
    }
    
    func testDeleteDocumentOpFailsValidationWhenRevIdIsMissing() {
        
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let db = client[self.dbName!]
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.docId = "testDocId"
        delete.deleteDocumentCompletionHandler = {(statusCode, error) in
            expectation.fulfill()
            XCTAssertNil(statusCode)
            XCTAssertNotNil(error)
        }
        
        db.add(operation: delete)
        self.waitForExpectations(withTimeout:10.0, handler: nil)

    }
    
    func testDeleteDocumentOpFailsValidationWhenDocIdIsMissing() {
        
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let db = client[self.dbName!]
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.docId = "testDocId"
        delete.deleteDocumentCompletionHandler = {(statusCode, error) in
            expectation.fulfill()
            XCTAssertNil(statusCode)
            XCTAssertNotNil(error)
        }
        
        db.add(operation: delete)
        self.waitForExpectations(withTimeout:10.0, handler: nil)
        
    }
    
    func testDeleteDocumentOpCompletesWithoutCallback() {
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let db = client[self.dbName!]
        let expectation = self.expectation(withDescription:"Delete document")
        let delete = DeleteDocumentOperation()
        delete.deleteDocumentCompletionHandler = {(statusCode, error) in
            XCTAssertNotNil(statusCode)
            if let statusCode = statusCode {
                XCTAssert(statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        
        let create = PutDocumentOperation()
        create.docId = "testId"
        create.body = ["hello":"world"]
        create.putDocumentCompletionHandler = {(docId,revId,statusCode,error) in
            delete.revId = revId
            delete.docId = docId
        }
        
        let get = GetDocumentOperation()
        get.docId = "testId"
        get.getDocumentCompletionHandler = {(document , error) in
                        expectation.fulfill()
                        XCTAssertNil(document)
                        XCTAssertNotNil(error)
            }
        
        delete.addDependency(create)
        get.addDependency(delete)
        
        db.add(operation: create)
        db.add(operation: delete)
        db.add(operation: get)
        
        self.waitForExpectations(withTimeout:10.0, handler: nil)
    }
}
