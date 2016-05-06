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
    var client: CouchDBClient? = nil
    
    override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        createDatabase(databaseName: dbName!, client: client!)
        
        print("Created database: \(dbName!)")
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }
    
    func testDocumentCanBeDeleted() {
        let db = client![self.dbName!]
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.deleteDocumentCompletionHandler = {(response, httpInfo, error) in
            expectation.fulfill()
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
            XCTAssertEqual(true,response?["ok"] as? Bool)
        }
        
        let create = PutDocumentOperation()
        create.docId = "testId"
        create.body = ["hello":"world"]
        create.putDocumentCompletionHandler = {(response, httpInfo, error) in
            delete.revId = response?["rev"] as? String
            delete.docId = response?["id"] as? String
        }
        
        delete.addDependency(create)
        
        db.add(operation: create)
        db.add(operation: delete)
        
        self.waitForExpectations(withTimeout:10.0, handler: nil)
        
    }
    
    func testDeleteDocumentOpFailsValidationWhenRevIdIsMissing() {
        
        let db = client![self.dbName!]
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.docId = "testDocId"
        delete.deleteDocumentCompletionHandler = {(response, httpInfo, error) in
            expectation.fulfill()
            XCTAssertNil(httpInfo)
            XCTAssertNotNil(error)
        }
        
        db.add(operation: delete)
        self.waitForExpectations(withTimeout:10.0, handler: nil)

    }
    
    func testDeleteDocumentOpFailsValidationWhenDocIdIsMissing() {
    
        let db = client![self.dbName!]
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.docId = "testDocId"
        delete.deleteDocumentCompletionHandler = {(response, httpInfo, error) in
            expectation.fulfill()
            XCTAssertNil(httpInfo)
            XCTAssertNotNil(error)
        }
        
        db.add(operation: delete)
        self.waitForExpectations(withTimeout:10.0, handler: nil)
        
    }
    
    func testDeleteDocumentOpCompletesWithoutCallback() {
        let db = client![self.dbName!]
        let expectation = self.expectation(withDescription:"Delete document")
        let delete = DeleteDocumentOperation()
        delete.deleteDocumentCompletionHandler = {(response, httpInfo, error) in
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        
        let create = PutDocumentOperation()
        create.docId = "testId"
        create.body = ["hello":"world"]
        create.putDocumentCompletionHandler = {(response, httpInfo, error) in
            delete.revId = response?["rev"] as? String
            delete.docId = response?["id"] as? String
        }
        
        let get = GetDocumentOperation()
        get.docId = "testId"
        get.getDocumentCompletionHandler = {(response, httpInfo, error) in
                        expectation.fulfill()
                        XCTAssertNil(response)
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
