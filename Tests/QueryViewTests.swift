//
//  QueryViewTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 25/04/2016.
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
import OHHTTPStubs
@testable import SwiftCloudant

public class QueryViewTests: XCTestCase {

    var dbName: String? = nil
    var client: CouchDBClient?

    override public func setUp() {
        super.setUp()
        dbName = generateDBName()
        client = CouchDBClient(url: NSURL(string: url)!, username: username, password: password)

        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return (request.url?.path?.contains("/_view/"))!
            }, withStubResponse: { (response) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(jsonObject: ["offset": 0,
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
                "total_rows": 2667],
                statusCode: 200,
                headers: [:])
        })
    }

    override public func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testViewGeneratesCorrectRequestUsingStartAndEndKeys() throws {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.descending = true
        view.endKey = "endkey"
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.stale = .Ok
        view.startKey = "startKey"
        view.databaseName = self.dbName

        XCTAssert(view.validate())
        try view.serialise()

        XCTAssertEqual("GET", view.httpMethod)
        XCTAssertNil(view.httpRequestBody)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems = [NSURLQueryItem(name: "descending", value: "true"),
            NSURLQueryItem(name: "endkey", value: "\"endkey\""),
            NSURLQueryItem(name: "include_docs", value: "true"),
            NSURLQueryItem(name: "inclusive_end", value: "true"),
            NSURLQueryItem(name: "limit", value: "4"),
            NSURLQueryItem(name: "skip", value: "0"),
            NSURLQueryItem(name: "stale", value: "ok"),
            NSURLQueryItem(name: "startkey", value: "\"startKey\"")]

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }

    func testViewGeneratesCorrectRequestUsingJsonStartAndEndKeys() throws {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.descending = true
        view.endKey = ["endkey", "endkey2"]
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.stale = .Ok
        view.startKey = ["startKey", "startKey2"]
        view.databaseName = self.dbName

        XCTAssert(view.validate())
        try view.serialise()

        XCTAssertEqual("GET", view.httpMethod)
        XCTAssertNil(view.httpRequestBody)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems: [NSURLQueryItem] = [NSURLQueryItem(name: "descending", value: "true"),
            NSURLQueryItem(name: "endkey", value: "[\"endkey\",\"endkey2\"]"),
            NSURLQueryItem(name: "include_docs", value: "true"),
            NSURLQueryItem(name: "inclusive_end", value: "true"),
            NSURLQueryItem(name: "limit", value: "4"),
            NSURLQueryItem(name: "skip", value: "0"),
            NSURLQueryItem(name: "stale", value: "ok"),
            NSURLQueryItem(name: "startkey", value: "[\"startKey\",\"startKey2\"]")]

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }

    func testViewGeneratesCorrectRequestUsingKey() throws {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.descending = true
        view.key = "testKey"
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.stale = .Ok
        view.databaseName = self.dbName

        XCTAssert(view.validate())
        try view.serialise()

        XCTAssertEqual("GET", view.httpMethod)
        XCTAssertNil(view.httpRequestBody)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems: [NSURLQueryItem] = [NSURLQueryItem(name: "descending", value: "true"),
            NSURLQueryItem(name: "key", value: "\"testKey\""),
            NSURLQueryItem(name: "include_docs", value: "true"),
            NSURLQueryItem(name: "inclusive_end", value: "true"),
            NSURLQueryItem(name: "limit", value: "4"),
            NSURLQueryItem(name: "skip", value: "0"),
            NSURLQueryItem(name: "stale", value: "ok")]

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }

    func testViewGeneratesCorrectRequestUsingKeys() {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.descending = true
        view.keys = ["testkey", ["testkey2", "testkey3"]]
        view.includeDocs = true
        view.inclusiveEnd = true
        view.limit = 4
        view.skip = 0
        view.stale = .Ok
        view.databaseName = self.dbName

        XCTAssert(view.validate())
        XCTAssertEqual("POST", view.httpMethod)
        XCTAssertNotNil(view.httpRequestBody)
        XCTAssertEqual("{\"keys\":[\"testkey\",[\"testkey2\",\"testkey3\"]]}",
            String(data: view.httpRequestBody!, encoding: NSUTF8StringEncoding))
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems: [NSURLQueryItem] = [NSURLQueryItem(name: "descending", value: "true"),
            NSURLQueryItem(name: "include_docs", value: "true"),
            NSURLQueryItem(name: "inclusive_end", value: "true"),
            NSURLQueryItem(name: "limit", value: "4"),
            NSURLQueryItem(name: "skip", value: "0"),
            NSURLQueryItem(name: "stale", value: "ok")]

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }

    func testViewGeneratesCorrectRequestForReduces() {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.group = true
        view.groupLevel = 3
        view.reduce = true
        view.databaseName = self.dbName

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.httpMethod)
        XCTAssertNil(view.httpRequestBody)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems: [NSURLQueryItem] = [NSURLQueryItem(name: "group", value: "true"),
            NSURLQueryItem(name: "group_level", value: "3"),
            NSURLQueryItem(name: "reduce", value: "true")]

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }

    func testViewHandlesResponsesCorrectly() {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"

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

        view.completionHandler = { (error) in
            completionHandler.fulfill()
            XCTAssertNil(error)
        }

        self.client?[self.dbName!].add(operation: view)
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }

    func testOperationValidationMissingDDoc() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.viewName = "view1"
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationMissingViewname() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.designDoc = "ddoc"
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationReduceOptionsWithReduceFalseGroup() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.designDoc = "ddoc"
        view.viewName = "view1"
        // reduce is true by default, so we need to explicitly set to false
        view.reduce = false
        view.group = true
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationReduceOptionsWithReduceFalseGroupLevel() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.designDoc = "ddoc"
        view.viewName = "view1"
        // reduce is true by default, so we need to explicitly set to false
        view.reduce = false
        view.groupLevel = 3
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationReduceWithReduceGroup() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.group = true
        view.reduce = true
        XCTAssert(view.validate())
    }

    func testOperationValidationReduceWithoutReduceGroup() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.group = true
        XCTAssert(view.validate())
    }

    func testOperationValidationReduceWithReduceGroupLevelWithoutGroup() {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.groupLevel = 3
        view.reduce = true
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationKeyAndKeys() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.key = "key"
        view.keys = ["key1", "key2"]
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationNoCompletionHandlers() {
        let view = QueryViewOperation()
        view.databaseName = "dbname"
        view.designDoc = "ddoc"
        view.viewName = "view1"
        XCTAssert(view.validate())
    }

    func testOperationValidationMissingDBName() {
        let view = QueryViewOperation()
        view.viewName = "myView"
        view.designDoc = "myddoc"
        XCTAssertFalse(view.validate())
    }

    func testViewGeneratesCorrectRequestStaleDefault() {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.databaseName = self.dbName

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.httpMethod)
        XCTAssertNil(view.httpRequestBody)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems: [NSURLQueryItem] = []

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }

    func testViewGeneratesCorrectRequestStaleOk() {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.databaseName = self.dbName
        view.stale = .Ok

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.httpMethod)
        XCTAssertNil(view.httpRequestBody)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems: [NSURLQueryItem] = [NSURLQueryItem(name: "stale", value: "ok")]

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }

    func testViewGeneratesCorrectRequestStaleUpdateAfter() {
        let view = QueryViewOperation()
        view.designDoc = "ddoc"
        view.viewName = "view1"
        view.databaseName = self.dbName
        view.stale = .UpdateAfter

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.httpMethod)
        XCTAssertNil(view.httpRequestBody)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.httpPath)

        let expectedQueryItems: [NSURLQueryItem] = [NSURLQueryItem(name: "stale", value: "update_after")]

        XCTAssert(expectedQueryItems.isEquivalent(to: view.queryItems))
    }
}
