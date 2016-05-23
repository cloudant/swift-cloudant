//
//  DeleteQueryIndexTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 18/05/2016.
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

public class DeleteQueryIndexTests: XCTestCase {
	var client: CouchDBClient? = nil
    var dbName: String? = nil
    
    
    override public func setUp() {
        super.setUp()
            OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
                return (request.url?.path?.contains("_index"))! && !(request.httpMethod! == "POST")
                }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                	if request.httpMethod == "DELETE" {
                        return OHHTTPStubsResponse(jsonObject: ["ok": true], statusCode: 200, headers: [:])
                	} else {
                        return OHHTTPStubsResponse(jsonObject: ["error": "Method not allowed."], statusCode: 405, headers: [:])
                	}
            })
        
        dbName = generateDBName()
        client = CouchDBClient(url: NSURL(string:self.url)!, username: self.username, password: self.password)
    }

    override public func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testCanDeleteJSONIndex() {
    	let deleteExpectation = self.expectation(withDescription: "delete json index")
    	let deleteIndex = DeleteQueryIndexOperation()
        deleteIndex.databaseName = dbName
    	deleteIndex.designDoc = "ddoc"
    	deleteIndex.indexName = "jsonIndex"
    	deleteIndex.type = .JSON
    	deleteIndex.completionHandler = {(response, httpStatus, error) in 
    		XCTAssertNotNil(response)
    		XCTAssertEqual(true, response?["ok"] as? Bool)
    		XCTAssertNotNil(httpStatus)
    		if let httpStatus = httpStatus {
    			XCTAssert(httpStatus.statusCode / 100 == 2)
    		}
    		XCTAssertNil(error)
    		deleteExpectation.fulfill()
    	}
    	self.client?.add(operation: deleteIndex)
    	self.waitForExpectations(withTimeout:10.0, handler:nil)
    }

    public func testCanDeleteTextIndex() {
    	let deleteExpectation = self.expectation(withDescription: "delete json index")
    	let deleteIndex = DeleteQueryIndexOperation()
        deleteIndex.databaseName = dbName
    	deleteIndex.designDoc = "ddoc"
    	deleteIndex.indexName = "textIndex"
    	deleteIndex.type = .Text
    	deleteIndex.completionHandler = {(response, httpStatus, error) in 
    		XCTAssertNotNil(response)
    		XCTAssertEqual(true, response?["ok"] as? Bool)
    		XCTAssertNotNil(httpStatus)
    		if let httpStatus = httpStatus {
    			XCTAssert(httpStatus.statusCode / 100 == 2)
    		}
    		XCTAssertNil(error)
    		deleteExpectation.fulfill()
    	}
    	self.client?.add(operation: deleteIndex)
    	self.waitForExpectations(withTimeout:10.0, handler:nil)
    }

    public func testValidationMissingDdoc() {
		let deleteIndex = DeleteQueryIndexOperation()
        deleteIndex.databaseName = dbName
    	deleteIndex.indexName = "textIndex"
    	deleteIndex.type = .Text
    	XCTAssertFalse(deleteIndex.validate())
    }

    public func testValidationMissingIndexName() {
    	let deleteIndex = DeleteQueryIndexOperation()
        deleteIndex.databaseName = dbName
    	deleteIndex.designDoc = "ddoc"
    	deleteIndex.type = .JSON
    	XCTAssertFalse(deleteIndex.validate())
    }

    public func testValidationMissingIndexType() {
    	let deleteIndex = DeleteQueryIndexOperation()
        deleteIndex.databaseName = dbName
    	deleteIndex.designDoc = "ddoc"
    	deleteIndex.indexName = "jsonIndex"
    	XCTAssertFalse(deleteIndex.validate())
    }

    public func testOperationPropertiesJSONIndex() {
    	let deleteIndex = DeleteQueryIndexOperation()
    	deleteIndex.designDoc = "ddoc"
    	deleteIndex.indexName = "jsonIndex"
    	deleteIndex.type = .JSON
    	deleteIndex.databaseName = "dbName"
    	XCTAssert(deleteIndex.validate())
    	XCTAssertEqual("DELETE", deleteIndex.method)
    	XCTAssertEqual("/dbName/_index/ddoc/json/jsonIndex", deleteIndex.endpoint)
    }

    public func testOperationPropertiesTextIndex() {
    	let deleteIndex = DeleteQueryIndexOperation()
    	deleteIndex.designDoc = "ddoc"
    	deleteIndex.indexName = "textIndex"
    	deleteIndex.type = .Text
    	deleteIndex.databaseName = "dbName"
    	XCTAssert(deleteIndex.validate())
    	XCTAssertEqual("DELETE", deleteIndex.method)
    	XCTAssertEqual("/dbName/_index/ddoc/text/textIndex", deleteIndex.endpoint)
    }
    
}
