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
@testable import SwiftCloudant

public class DeleteQueryIndexTests: XCTestCase {
	
    static var allTests = {
        return [
            ("testCanDeleteJSONIndex", testCanDeleteJSONIndex),
            ("testCanDeleteTextIndex",testCanDeleteTextIndex),
            ("testOperationPropertiesJSONIndex",testOperationPropertiesJSONIndex),
            ("testOperationPropertiesTextIndex",testOperationPropertiesTextIndex),]
    }()
    
    var client: CouchDBClient? = nil
    var dbName: String? = nil
    
    
    override public func setUp() {
        super.setUp()
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string:self.url)!, username: self.username, password: self.password)
    }

    override public func tearDown() {
        super.tearDown()
    }

    func testCanDeleteJSONIndex() {
    	let deleteExpectation = self.expectation(description: "delete json index")
    	let deleteIndex = DeleteQueryIndexOperation(name: "jsonIndex", type: .json, designDocumentID: "ddoc", databaseName: dbName!)
    	 {(response, httpStatus, error) in
    		XCTAssertNotNil(response)
    		XCTAssertEqual(true, response?["ok"] as? Bool)
    		XCTAssertNotNil(httpStatus)
    		if let httpStatus = httpStatus {
    			XCTAssert(httpStatus.statusCode / 100 == 2)
    		}
    		XCTAssertNil(error)
    		deleteExpectation.fulfill()
    	}
    	self.simulateOkResponseFor(operation: deleteIndex)
    	self.waitForExpectations(timeout:10.0, handler:nil)
    }

    public func testCanDeleteTextIndex() {
    	let deleteExpectation = self.expectation(description: "delete json index")
    	let deleteIndex = DeleteQueryIndexOperation(name: "textIndex", type: .text, designDocumentID: "ddoc", databaseName: dbName!)
    	 {(response, httpStatus, error) in 
    		XCTAssertNotNil(response)
    		XCTAssertEqual(true, response?["ok"] as? Bool)
    		XCTAssertNotNil(httpStatus)
    		if let httpStatus = httpStatus {
    			XCTAssert(httpStatus.statusCode / 100 == 2)
    		}
    		XCTAssertNil(error)
    		deleteExpectation.fulfill()
    	}
    	self.simulateOkResponseFor(operation: deleteIndex)
    	self.waitForExpectations(timeout:10.0, handler:nil)
    }

    public func testOperationPropertiesJSONIndex() {
    	let deleteIndex = DeleteQueryIndexOperation(name: "jsonIndex", type: .json, designDocumentID: "ddoc", databaseName: "dbName")
    	XCTAssert(deleteIndex.validate())
    	XCTAssertEqual("DELETE", deleteIndex.method)
    	XCTAssertEqual("/dbName/_index/ddoc/json/jsonIndex", deleteIndex.endpoint)
    }

    public func testOperationPropertiesTextIndex() {
    	let deleteIndex = DeleteQueryIndexOperation(name: "textIndex", type: .text, designDocumentID: "ddoc", databaseName: "dbName")
    	XCTAssert(deleteIndex.validate())
    	XCTAssertEqual("DELETE", deleteIndex.method)
    	XCTAssertEqual("/dbName/_index/ddoc/text/textIndex", deleteIndex.endpoint)
    }
    
}
