//
//  GetAllDocumentsTests.swift
//  SwiftCloudant
//
//  Created by Taylor Franklin on 7/8/16.
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


public class GetAllDocumentsTests : XCTestCase {

    var client: CouchDBClient? = nil;
    var dbName: String? = nil
    let response = ["offset": 0,
                    "rows": [["id": "3-tiersalmonspinachandavocadoterrine",
                              "key": "3-tier salmon, spinach and avocado terrine",
                              "value": ["3-tier salmon, spinach and avocado terrine"]],
                             ["id": "Aberffrawcake",
                              "key": "Aberffraw cake",
                              "value": ["Aberffraw cake"]],
                             ["id": "Adukiandorangecasserole-microwave",
                              "key": "Aduki and orange casserole - microwave",
                              "value": ["Aduki and orange casserole - microwave"]],
                             ["id": "Aioli-garlicmayonnaise",
                              "key": "Aioli - garlic mayonnaise",
                              "value": ["Aioli - garlic mayonnaise"]],
                             ["id": "Alabamapeanutchicken",
                              "key": "Alabama peanut chicken",
                              "value": ["Alabama peanut chicken"]]],
                    "total_rows": 2667]
    
    public override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: NSURL(string:self.url)!, username: self.username, password: self.password)
    }
    
    override public func tearDown() {
        super.tearDown()
    }
    
    func testViewGeneratesCorrectRequestUsingStartAndEndKeys() throws {
        let view = GetAllDocumentsOperation()
        view.descending = true
        view.endKey = "endkey"
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.startKey = "startKey"
        view.databaseName = self.dbName
        
        XCTAssert(view.validate())
        try view.serialise()
        
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_all_docs", view.endpoint)
        
        let expectedQueryItems = ["descending": "true",
              "endkey": "\"endkey\"",
              "include_docs": "true",
              "inclusive_end": "true",
              "limit": "4",
              "skip": "0",
              "startkey": "\"startKey\""]
        
        XCTAssertEqual(expectedQueryItems, view.parameters)
    }
    
    func testViewGeneratesCorrectRequestUsingJsonStartAndEndKeys() throws {
        let view = GetAllDocumentsOperation()
        view.descending = true
        view.endKey = ["endkey", "endkey2"]
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.startKey = ["startKey", "startKey2"]
        view.databaseName = self.dbName
        
        XCTAssert(view.validate())
        try view.serialise()
        
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_all_docs", view.endpoint)
        
        let expectedQueryItems = ["descending": "true",
              "endkey": "[\"endkey\",\"endkey2\"]",
              "include_docs": "true",
              "inclusive_end": "true",
              "limit": "4",
              "skip": "0",
              "startkey": "[\"startKey\",\"startKey2\"]"]
        
        XCTAssertEqual(expectedQueryItems, view.parameters)
    }
    
    func testViewGeneratesCorrectRequestUsingKey() throws {
        let view = GetAllDocumentsOperation()
        view.descending = true
        view.key = "testKey"
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.databaseName = self.dbName
        
        XCTAssert(view.validate())
        try view.serialise()
        
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_all_docs", view.endpoint)
        
        let expectedQueryItems = ["descending": "true",
                                  "key": "\"testKey\"",
                                  "include_docs": "true",
                                  "inclusive_end": "true",
                                  "limit": "4",
                                  "skip": "0"]
        print("View: \(view.parameters)")
        XCTAssertEqual(expectedQueryItems, view.parameters)
    }
    
    func testViewGeneratesCorrectRequestUsingKeys() {
        let view = GetAllDocumentsOperation()
        view.descending = true
        view.keys = ["testkey", ["testkey2", "testkey3"]]
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.databaseName = self.dbName
        
        XCTAssert(view.validate())
        XCTAssertEqual("POST", view.method)
        XCTAssertNotNil(view.data)
        XCTAssertEqual("{\"keys\":[\"testkey\",[\"testkey2\",\"testkey3\"]]}",
                       String(data: view.data!, encoding: NSUTF8StringEncoding))
        XCTAssertEqual("/\(self.dbName!)/_all_docs", view.endpoint)
        
        let expectedQueryItems = ["descending": "true",
                                  "include_docs": "true",
                                  "inclusive_end": "true",
                                  "limit": "4",
                                  "skip": "0"]
        
        XCTAssertEqual(expectedQueryItems, view.parameters)
    }
    
    func testViewHandlesResponsesCorrectly() {
        let view = GetAllDocumentsOperation()
        view.databaseName = dbName
        
        var rowCount = 0
        var first = true
        let rowHandler = self.expectation(withDescription: "row handler")
        let completionHandler = self.expectation(withDescription: "completion handler")
        view.rowHandler = { (row) in
            if (first) {
                rowHandler.fulfill()
                first = false
            }
            rowCount += 1
            XCTAssertNotNil(row)
        }
        
        view.completionHandler = { (response, httpInfo, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            completionHandler.fulfill()
        }
        self.simulateOkResponseFor(operation: view, jsonResponse:JSONResponse(dictionary: response))
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testOperationValidationKeyAndKeys() {
        let view = GetAllDocumentsOperation()
        view.databaseName = "dbname"
        view.key = "key"
        view.keys = ["key1", "key2"]
        XCTAssertFalse(view.validate())
    }
    
    func testOperationValidationNoCompletionHandlers() {
        let view = GetAllDocumentsOperation()
        view.databaseName = "dbname"
        XCTAssert(view.validate())
    }
    
    func testOperationValidationMissingDBName() {
        let view = GetAllDocumentsOperation()
        XCTAssertFalse(view.validate())
    }

}