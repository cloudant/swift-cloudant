//
//  BulkDocsTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 27/07/2016.
//
//  Copyright (C) 2016 IBM Corp.
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

class BulkDocsTests : XCTestCase {
    
    var dbName: String? = nil
    var client: CouchDBClient? = nil
    let docs:[[String:Any]] = [["hello":"world"], ["foo": "bar"]]
    
    override func setUp() {
        super.setUp()
        self.dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }
    
    func testValidationOnlyDocs() {
    
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!, documents: docs)
        XCTAssert(bulk.validate())
    }
    
    func testValidationNewEdits() {
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!, documents: docs, newEdits: false)
        XCTAssert(bulk.validate())
    }
    
    func testValidationAllOrNothing() {
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!, documents: docs, allOrNothing: true)
        XCTAssert(bulk.validate())
    }
    
    func testGeneratedPayloadAllOptions() throws {
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!, documents: docs, newEdits: false, allOrNothing: true)
        XCTAssert(bulk.validate())
        
        try bulk.serialise()
        
        let data =  bulk.data
        XCTAssertNotNil(data)
        
        XCTAssertEqual("POST", bulk.method)
        if let data = data {
            
            let requestJson = try JSONSerialization.jsonObject(with: data) as! NSDictionary
            
            
            let expected: [String: Any] = ["docs":[["hello":"world"],["foo":"bar"]], "new_edits":false, "all_or_nothing":true]
            
            XCTAssertEqual(expected as NSDictionary, requestJson)
        }
    }
   
    func testGeneratedPayloadNewEdits() throws {
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!, documents: docs, newEdits: false)
        XCTAssert(bulk.validate())
        
        try bulk.serialise()
        
        let data =  bulk.data
        XCTAssertNotNil(data)
        
        XCTAssertEqual("POST", bulk.method)
        if let data = data {
            
            let requestJson = try JSONSerialization.jsonObject(with: data) as! NSDictionary
            
            let expected: [String: Any] = ["docs":[["hello":"world"],["foo":"bar"]], "new_edits":false]
            XCTAssertEqual(expected as NSDictionary, requestJson)
        }
    }
    
    func testGeneratedPayloadAllOrNothing() throws {
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!, documents: docs, allOrNothing: true)
        XCTAssert(bulk.validate())
        
        try bulk.serialise()
        
        let data =  bulk.data
        XCTAssertNotNil(data)
        
        XCTAssertEqual("POST", bulk.method)
        if let data = data {
            
            let requestJson = try JSONSerialization.jsonObject(with: data) as! NSDictionary
            
            let expected: [String: Any] = ["docs":[["hello":"world"],["foo":"bar"]], "all_or_nothing":true]
            XCTAssertEqual(expected as NSDictionary, requestJson)
        }
    }
    
    func testCompleteRequest() throws {
        let expectation = self.expectation(description: "bulk insert")
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!, documents: docs) { (response, httpInfo, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpInfo)
            
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            
            if let response = response {
                XCTAssertEqual(2,response.count)
                
                for doc in response {
                    
                    if let ok = doc["ok"] as? Bool {
                        XCTAssertEqual(true, ok)
                    }
                    
                }
            }
            expectation.fulfill()
        
        }
        
        client?.add(operation: bulk)
        self.waitForExpectations(timeout: 10.0)
        
        // Check that all the documents are in the db
        let getDocsExpect = self.expectation(description: "get all docs")
        let allDocs = GetAllDocsOperation(databaseName: dbName!){ (response, httpInfo, error) in
            
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpInfo)
            XCTAssertNil(error)
            
            if let response = response, let httpInfo = httpInfo {
                XCTAssertEqual(2, httpInfo.statusCode / 100)
                XCTAssertNotNil(response["rows"])
                if let rows = response["rows"] as? [String] {
                    XCTAssertEqual(2, rows.count)
                }
            }
            getDocsExpect.fulfill()
        }
        self.client?.add(operation: allDocs)
        self.waitForExpectations(timeout: 10.0)
    }
    
}
