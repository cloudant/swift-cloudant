//
//  GetDocumentTests.swift
//  SwiftCloudant
//
//  Created by Stefan Kruger on 04/03/2016.
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

class GetDocumentTests: XCTestCase {

    var dbName: String? = nil
    var client: CouchDBClient? = nil

    override func setUp() {
        super.setUp()

        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
    }

    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)

        super.tearDown()

        print("Deleted database: \(dbName!)")
    }

    func testPutDocument() {
        let data = createTestDocuments(count: 1)

        let putDocumentExpectation = expectation(withDescription: "put document")
        let client = CouchDBClient(url: URL(string: url)!, username: username, password: password)

        let put = PutDocumentOperation()
        put.databaseName = dbName
        put.body = data[0]
        put.docId = UUID().uuidString.lowercased()

        put.completionHandler = { (response, httpInfo, error) in
            putDocumentExpectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode == 201 || httpInfo.statusCode == 202)
            }
        }

        client.add(operation: put)

        waitForExpectations(withTimeout: 10.0, handler: nil)
    }

    func testGetDocument() {
        let data = createTestDocuments(count: 1)
        let getDocumentExpectation = expectation(withDescription: "get document")

        let putDocumentExpectation = self.expectation(withDescription: "put document")
        let put = PutDocumentOperation()
        put.body = data[0]
        put.docId = UUID().uuidString.lowercased()
        put.databaseName = self.dbName
        put.completionHandler = { (response, httpInfo, operationError) in
            putDocumentExpectation.fulfill()
            XCTAssertEqual(put.docId, response?["id"] as? String);
            XCTAssertNotNil(response?["rev"])
            XCTAssertNil(operationError)
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssertTrue(httpInfo.statusCode / 100 == 2)
            }

            let get = GetDocumentOperation()
            get.docId = put.docId
            get.databaseName = self.dbName

            get.completionHandler = { (response, httpInfo, error) in
                getDocumentExpectation.fulfill()
                XCTAssertNil(error)
                XCTAssertNotNil(response)
            }

            self.client!.add(operation: get)
        };
        
        let nsPut = Operation(couchOperation: put)
        client?.add(operation: nsPut)
        nsPut.waitUntilFinished()

        waitForExpectations(withTimeout: 10.0, handler: nil)
    }

    func testGetDocumentUsingDBAdd() {
        let data = createTestDocuments(count: 1)
        let getDocumentExpectation = expectation(withDescription: "get document")
        let client = CouchDBClient(url: URL(string: url)!, username: username, password: password)

        let putDocumentExpectation = self.expectation(withDescription: "put document")
        let put = PutDocumentOperation()
        put.databaseName = dbName
        put.body = data[0]
        put.docId = UUID().uuidString.lowercased()
        put.completionHandler = { (response, httpInfo, operationError) in
            putDocumentExpectation.fulfill()
            XCTAssertEqual(put.docId, response?["id"] as? String);
            XCTAssertNotNil(response?["rev"])
            XCTAssertNil(operationError)
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssertTrue(httpInfo.statusCode / 100 == 2)
            }

        };
        
        let nsPut = Operation(couchOperation: put)
        client.add(operation: nsPut)
        nsPut.waitUntilFinished()

        let get = GetDocumentOperation()
        get.docId = put.docId
        get.databaseName = self.dbName

        get.completionHandler = { (response, httpInfo, error) in
            getDocumentExpectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssertEqual(200, httpInfo.statusCode)
            }
        }

        client.add(operation: get)

        waitForExpectations(withTimeout: 10.0, handler: nil)
    }
}
