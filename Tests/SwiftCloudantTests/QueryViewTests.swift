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
@testable import SwiftCloudant

public class QueryViewTests: XCTestCase {

    static var allTests = {
        return [
            ("testViewGeneratesCorrectRequestUsingStartAndEndKeys", testViewGeneratesCorrectRequestUsingStartAndEndKeys),
            ("testViewGeneratesCorrectRequestUsingJsonStartAndEndKeys",testViewGeneratesCorrectRequestUsingJsonStartAndEndKeys),
            ("testViewGeneratesCorrectRequestUsingKey",testViewGeneratesCorrectRequestUsingKey),
            ("testViewGeneratesCorrectRequestUsingKeys",testViewGeneratesCorrectRequestUsingKeys),
            ("testViewGeneratesCorrectRequestForReduces",testViewGeneratesCorrectRequestForReduces),
            ("testViewHandlesResponsesCorrectly",testViewHandlesResponsesCorrectly),
            ("testOperationValidationReduceOptionsWithReduceFalseGroup",testOperationValidationReduceOptionsWithReduceFalseGroup),
            ("testOperationValidationReduceOptionsWithReduceFalseGroupLevel",testOperationValidationReduceOptionsWithReduceFalseGroupLevel),
            ("testOperationValidationReduceWithReduceGroup",testOperationValidationReduceWithReduceGroup),
            ("testOperationValidationReduceWithoutReduceGroup",testOperationValidationReduceWithoutReduceGroup),
            ("testOperationValidationReduceWithReduceGroupLevelWithoutGroup",testOperationValidationReduceWithReduceGroupLevelWithoutGroup),
            ("testOperationValidationKeyAndKeys",testOperationValidationKeyAndKeys),
            ("testOperationValidationNoCompletionHandlers",testOperationValidationNoCompletionHandlers),
            ("testViewGeneratesCorrectRequestStaleDefault",testViewGeneratesCorrectRequestStaleDefault),
            ("testViewGeneratesCorrectRequestStaleOk",testViewGeneratesCorrectRequestStaleOk),
            ("testViewGeneratesCorrectRequestStaleUpdateAfter",testViewGeneratesCorrectRequestStaleUpdateAfter),
            ("testViewGeneratesCorrectRequestUpdateSeq",testViewGeneratesCorrectRequestUpdateSeq),]
    }()
    
    var dbName: String? = nil
    var client: CouchDBClient?
    lazy var response:[String: Any] = {() -> [String:Any] in
        
        let rows:[[String:Any]] = [["id": "3-tiersalmonspinachandavocadoterrine",
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
                     "value": ["Alabama peanut chicken"]]]
        
           return ["offset": 0,
                    "rows": rows,
                    "total_rows": 2667]
    }()

    override public func setUp() {
        super.setUp()
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
    }

    override public func tearDown() {
        super.tearDown()
    }

    func testViewGeneratesCorrectRequestUsingStartAndEndKeys() throws {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!,
                                      descending: true,
                                      startKey: "startKey",
                                      endKey: "endkey",
                                      inclusiveEnd: true,
                                      limit: 4,
                                      skip: 0,
                                      includeDocs: true,
                                      stale: .ok)
        XCTAssert(view.validate())
        try view.serialise()

        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)

        let expectedQueryItems = ["descending": "true",
            "endkey": "\"endkey\"",
            "include_docs": "true",
            "inclusive_end": "true",
            "limit": "4",
            "skip": "0",
            "stale": "ok",
            "startkey": "\"startKey\""]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }

    func testViewGeneratesCorrectRequestUsingJsonStartAndEndKeys() throws {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!,
                                      descending: true,
                                      startKey: ["startKey", "startKey2"],
                                      endKey: ["endkey", "endkey2"],
                                      inclusiveEnd: true,
                                      limit: 4,
                                      skip: 0,
                                      includeDocs: true,
                                      stale: .ok)

        XCTAssert(view.validate())
        try view.serialise()

        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)

        let expectedQueryItems = ["descending": "true",
            "endkey": "[\"endkey\",\"endkey2\"]",
            "include_docs": "true",
            "inclusive_end": "true",
            "limit": "4",
            "skip": "0",
            "stale": "ok",
            "startkey": "[\"startKey\",\"startKey2\"]"]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }

    func testViewGeneratesCorrectRequestUsingKey() throws {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!,
                                      descending: true,
                                      inclusiveEnd: true,
                                      key: "testKey",
                                      limit: 4,
                                      skip: 0,
                                      includeDocs: true,
                                      stale: .ok)

        XCTAssert(view.validate())
        try view.serialise()

        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)

        let expectedQueryItems = ["descending": "true",
            "key": "\"testKey\"",
            "include_docs": "true",
            "inclusive_end": "true",
            "limit": "4",
            "skip": "0",
            "stale": "ok"]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }

    func testViewGeneratesCorrectRequestUsingKeys() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!,
                                      descending: true,
                                      inclusiveEnd :true,
                                      keys: ["testkey", ["testkey2", "testkey3"]],
                                      limit : 4,
                                      skip : 0,
                                      includeDocs : true,
            stale : .ok)

        XCTAssert(view.validate())
        XCTAssertEqual("POST", view.method)
        XCTAssertNotNil(view.data)
        XCTAssertEqual("{\"keys\":[\"testkey\",[\"testkey2\",\"testkey3\"]]}",
            String(data: view.data!, encoding: String.Encoding.utf8))
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)

        let expectedQueryItems = ["descending": "true",
            "include_docs": "true",
            "inclusive_end": "true",
            "limit": "4",
            "skip": "0",
            "stale": "ok"]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }

    func testViewGeneratesCorrectRequestForReduces() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!,
                                      reduce : true,
                                      group : true,
                                      groupLevel : 3)

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)

        let expectedQueryItems = ["group": "true",
            "group_level": "3",
            "reduce": "true"]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }

    func testViewHandlesResponsesCorrectly() {
        

        var rowCount = 0
        var first = true
        let rowHandler = self.expectation(description: "row handler")
        let completionHandler = self.expectation(description: "completion handler")
        
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!,
                                      rowHandler: { (row) in
            if (first) {
                rowHandler.fulfill()
                first = false
            }
            rowCount += 1
            XCTAssertNotNil(row)
        }) { (response, httpInfo, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            completionHandler.fulfill()
        }
        self.simulateOkResponseFor(operation: view, jsonResponse:JSONResponse(dictionary:response))
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testOperationValidationReduceOptionsWithReduceFalseGroup() {
        // reduce is true by default, so we need to explicitly set to false
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, reduce: false, group: true)
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationReduceOptionsWithReduceFalseGroupLevel() {
        // reduce is true by default, so we need to explicitly set to false
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!,reduce: false, groupLevel: 3)
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationReduceWithReduceGroup() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, reduce: true, group: true)
        XCTAssert(view.validate())
    }

    func testOperationValidationReduceWithoutReduceGroup() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, group: true)
        XCTAssert(view.validate())
    }

    func testOperationValidationReduceWithReduceGroupLevelWithoutGroup() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, reduce: true, groupLevel:3)
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationKeyAndKeys() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, key: "key", keys: ["key1", "key2"])
        XCTAssertFalse(view.validate())
    }

    func testOperationValidationNoCompletionHandlers() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!)
        XCTAssert(view.validate())
    }

    func testViewGeneratesCorrectRequestStaleDefault() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!)

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)

        let expectedQueryItems:[String:String] = [:]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }

    func testViewGeneratesCorrectRequestStaleOk() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, stale: .ok)

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)

        let expectedQueryItems = ["stale": "ok"]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }

    func testViewGeneratesCorrectRequestStaleUpdateAfter() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, stale: .updateAfter)

        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)
	
        let expectedQueryItems = ["stale": "update_after"]

        XCTAssertEqual(expectedQueryItems, view.parameters)
    }
    
    func testViewGeneratesCorrectRequestUpdateSeq() {
        let view = QueryViewOperation(name: "view1", designDocumentID: "ddoc", databaseName: self.dbName!, includeLastUpdateSequenceNumber: true)
        
        XCTAssert(view.validate())
        XCTAssertEqual("GET", view.method)
        XCTAssertNil(view.data)
        XCTAssertEqual("/\(self.dbName!)/_design/ddoc/_view/view1", view.endpoint)
        
        let expectedQueryItems = ["update_seq": "true"]
        
        XCTAssertEqual(expectedQueryItems, view.parameters)
    }
}
