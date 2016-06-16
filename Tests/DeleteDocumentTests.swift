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

class DeleteDocumentTests: XCTestCase {
    var dbName: String? = nil
    var client: CouchDBClient? = nil

    override func setUp() {
        super.setUp()

        dbName = generateDBName()
        client = CouchDBClient(url: NSURL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)

        print("Created database: \(dbName!)")
    }

    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }

    func testDocumentCanBeDeleted() {
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.completionHandler = { (response, httpInfo, error) in
            expectation.fulfill()
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
            XCTAssertEqual(true, response?["ok"] as? Bool)
        }

        let create = PutDocumentOperation()
        create.docId = "testId"
        create.body = ["hello": "world"]
        create.completionHandler = { (response, httpInfo, error) in
            delete.revId = response?["rev"] as? String
            delete.docId = response?["id"] as? String
        }
        
        create.databaseName = dbName
        delete.databaseName = dbName

        let nsCreate = Operation(couchOperation: create)
        let nsDelete = Operation(couchOperation: delete)
        nsDelete.addDependency(nsCreate)
        
        client?.add(operation: nsCreate)
        client?.add(operation: nsDelete)

        self.waitForExpectations(withTimeout: 10.0, handler: nil)

    }

    func testDeleteDocumentOpFailsValidationWhenRevIdIsMissing() {

        
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.databaseName = dbName
        delete.docId = "testDocId"
        delete.completionHandler = { (response, httpInfo, error) in
            expectation.fulfill()
            XCTAssertNil(httpInfo)
            XCTAssertNotNil(error)
        }

        client?.add(operation: delete)
        self.waitForExpectations(withTimeout: 10.0, handler: nil)

    }

    func testDeleteDocumentOpFailsValidationWhenDocIdIsMissing() {

        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.databaseName = dbName
        delete.docId = "testDocId"
        delete.completionHandler = { (response, httpInfo, error) in
            expectation.fulfill()
            XCTAssertNil(response)
            XCTAssertNil(httpInfo)
            XCTAssertNotNil(error)
        }

        client?.add(operation: delete)
        self.waitForExpectations(withTimeout: 10.0, handler: nil)

    }

    func testDeleteDocumentOpCompletesWithoutCallback() {
        let expectation = self.expectation(withDescription: "Delete document")
        let delete = DeleteDocumentOperation()
        delete.databaseName = dbName
        delete.completionHandler = { (response, httpInfo, error) in
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }

        let create = PutDocumentOperation()
        create.docId = "testId"
        create.body = ["hello": "world"]
        create.databaseName = dbName
        create.completionHandler = { (response, httpInfo, error) in
            delete.revId = response?["rev"] as? String
            delete.docId = response?["id"] as? String
        }

        let get = GetDocumentOperation()
        get.docId = "testId"
        get.databaseName = dbName
        get.completionHandler = { (response, httpInfo, error) in
            expectation.fulfill()
            XCTAssertNotNil(response)
            XCTAssertNotNil(error)
        }
        
        let nsDelete = Operation(couchOperation: delete)
        let nsCreate = Operation(couchOperation: create)
        let nsGet = Operation(couchOperation: get)
        nsDelete.addDependency(nsCreate)
        nsGet.addDependency(nsDelete)

        client?.add(operation: nsCreate)
        client?.add(operation: nsDelete)
        client?.add(operation: nsGet)

        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
}
