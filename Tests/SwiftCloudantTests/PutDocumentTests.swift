//
//  File.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 26/03/2016.
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

class PutDocumentTests: XCTestCase {
    var client: CouchDBClient? = nil;
    var dbName: String? = nil

    override func setUp() {
        super.setUp()

        dbName = generateDBName()
        self.client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
    }

    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }

    func testSaveDocument() {
        let putExpectation = self.expectation(description: "Put Document expectation")
        let put = PutDocumentOperation(id: "Doc1", body:["hello": "world"], databaseName: dbName!) { (response, httpInfo, error) in
            putExpectation.fulfill()
            XCTAssertEqual("Doc1", response?["id"] as? String)
            XCTAssertNotNil(response?["rev"])
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssertEqual(2, httpInfo.statusCode / 100)
            }

        }
        client?.add(operation: put)

        self.waitForExpectations(timeout: 10) { (_) in

        }

    }
    
    func testSaveDocumentWithoutId() {
        let putExpectation = self.expectation(description: "Put Document expectation")
        let put = PutDocumentOperation(body:["hello": "world"], databaseName: dbName!) { (response, httpInfo, error) in
            putExpectation.fulfill()
            XCTAssertNotNil(response?["id"] as? String)
            XCTAssertNotNil(response?["rev"])
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssertEqual(2, httpInfo.statusCode / 100)
            }
            
        }
        client?.add(operation: put)
        
        self.waitForExpectations(timeout: 10) { (_) in
            
        }
    }
    
    func testOperationRequestMissingId() throws {
        let put = PutDocumentOperation(body:["hello": "world"], databaseName: dbName!)
        XCTAssertTrue(put.validate())
        XCTAssertEqual(put.method, "POST")
        XCTAssertEqual(put.endpoint, "/\(self.dbName!)")
        XCTAssertEqual([:] as [String:String], put.parameters)
        try put.serialise()
        
        let json = try JSONSerialization.jsonObject(with: put.data!) as? [String:String]
        
        if let json = json {
            XCTAssertEqual(["hello":"world"], json)
        }else {
            XCTFail("JSON data was nil")
        }
    }
    
    func testOperationRequestWithId() throws {
        let put = PutDocumentOperation(id: "doc1", body:["hello": "world"], databaseName: dbName!)
        XCTAssertTrue(put.validate())
        XCTAssertEqual(put.method, "PUT")
        XCTAssertEqual(put.endpoint, "/\(self.dbName!)/doc1")
        XCTAssertEqual([:] as [String:String], put.parameters)
        try put.serialise()
        
        let json = try JSONSerialization.jsonObject(with: put.data!) as? [String:String]
        
        if let json = json {
            XCTAssertEqual(["hello":"world"], json)
        }else {
            XCTFail("JSON data was nil")
        }
    }
    
    func testOperationRequestWithRev() throws {
        let put = PutDocumentOperation(id: "doc1", revision:"1-rev", body:["hello": "world"], databaseName: dbName!)
        XCTAssertTrue(put.validate())
        XCTAssertEqual(put.method, "PUT")
        XCTAssertEqual(put.endpoint, "/\(self.dbName!)/doc1")
        XCTAssertEqual(["rev":"1-rev"] as [String:String], put.parameters)
        try put.serialise()
        
        let json = try JSONSerialization.jsonObject(with: put.data!) as? [String:String]
        
        if let json = json {
            XCTAssertEqual(["hello":"world"], json)
        }else {
            XCTFail("JSON data was nil")
        }
    }
    
}
