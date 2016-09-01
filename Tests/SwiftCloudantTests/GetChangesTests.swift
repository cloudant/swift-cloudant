//
//  GetChangesTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 23/08/2016.
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


class GetChangesTests : XCTestCase {
    
    static var allTests = {
        return [
            ("testChangesFeedDefaults", testChangesFeedDefaults),
            ("testChangesFeedMixedQuery",testChangesFeedMixedQuery),
            ("testRequestPropertiesDocIds",testRequestPropertiesDocIds),
            ("testRequestPropertiesConflicts",testRequestPropertiesConflicts),
            ("testRequestPropertiesDescending",testRequestPropertiesDescending),
            ("testRequestPropertiesFilter",testRequestPropertiesFilter),
            ("testRequestPropertiesIncludeDocs",testRequestPropertiesIncludeDocs),
            ("testRequestPropertiesincludeAttachments",testRequestPropertiesincludeAttachments),
            ("testRequestPropertiesIncludeAttachmentInfo",testRequestPropertiesIncludeAttachmentInfo),
            ("testRequestPropertiesLimit",testRequestPropertiesLimit),
            ("testReuqestPropertiesSince",testReuqestPropertiesSince),
            ("testRequestPropertiesStyle",testRequestPropertiesStyle),
            ("testRequestPropertiesView",testRequestPropertiesView),]
    }()
    
    var dbName: String? = nil
    var client: CouchDBClient? = nil
    
    override func setUp() {
        super.setUp()
        self.dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
        
        let bulk = PutBulkDocsOperation(databaseName: dbName!,
                                        documents: self.createTestDocuments(count: 4))
        client?.add(operation: bulk).waitUntilFinished()
        
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }
    
    
    func testChangesFeedDefaults() throws {
        let expectation = self.expectation(description: "changes")
        
        var changeCount = 0
        let changes = GetChangesOperation(databaseName: dbName!, changeHandler: {(change) in
            changeCount += 1
            }
        ) { (response, info, error) in
            XCTAssertNotNil(response)
            XCTAssertNotNil(info)
            XCTAssertNil(error)
            if let info = info {
                XCTAssertEqual(200, info.statusCode)
            }
            
            expectation.fulfill()
        }
        
        client?.add(operation: changes)
        self.waitForExpectations(timeout: 10.0)
        XCTAssertEqual(4, changeCount)
    }
    
    func testChangesFeedMixedQuery() throws {
        let expectation = self.expectation(description: "changes")
        
        var docID: String?
        let allDocs = GetAllDocsOperation(databaseName: dbName!){ (response, info, error) in
            if let rows = response?["rows"] as? [[String: Any]],
               let first = rows.first {
                docID = first["key"] as? String
            }
        }
        client?.add(operation: allDocs).waitUntilFinished()
        var changeCount = 0
        let changes = GetChangesOperation(databaseName: dbName!, docIDs: [docID!], limit: 1, changeHandler: {(change) in
            changeCount += 1
            }){
            (response, info, error) in
            XCTAssertNotNil(response)
            XCTAssertNotNil(info)
            XCTAssertNil(error)
            if let info = info {
                XCTAssertEqual(200, info.statusCode)
            }
            expectation.fulfill()
        }

        client?.add(operation: changes)
        self.waitForExpectations(timeout: 10.0)
        XCTAssertEqual(1, changeCount)
        
        
    }
    
    func testRequestPropertiesDocIds() throws {
        let changes = GetChangesOperation(databaseName: dbName!, docIDs: ["test"])
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("POST", changes.method)
        XCTAssertEqual(try JSONSerialization.data(withJSONObject: ["doc_ids": ["test"]]), changes.data)
        XCTAssertEqual("/\(dbName!)/_changes", changes.endpoint)
        XCTAssertEqual([:], changes.parameters)
    }
    
    func testRequestPropertiesConflicts() throws {
        let changes = GetChangesOperation(databaseName: dbName!, conflicts: true)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["conflicts":"true"], changes.parameters)

    }
    
    func testRequestPropertiesDescending() throws {
        let changes = GetChangesOperation(databaseName: dbName!, descending: true)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["descending":"true"], changes.parameters)
    }
    
    func testRequestPropertiesFilter() throws {
        let changes = GetChangesOperation(databaseName: dbName!, filter: "myfilter")
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["filter":"myfilter"], changes.parameters)
    }
    
    func testRequestPropertiesIncludeDocs() throws {
        let changes = GetChangesOperation(databaseName: dbName!, includeDocs: true)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["include_docs":"true"], changes.parameters)
    }
    
    func testRequestPropertiesincludeAttachments() throws {
        let changes = GetChangesOperation(databaseName: dbName!, includeAttachments: true)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["attachments":"true"], changes.parameters)
    }
    
    func testRequestPropertiesIncludeAttachmentInfo() throws {
        let changes = GetChangesOperation(databaseName: dbName!, includeAttachmentEncodingInformation: true)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["att_encoding_info":"true"], changes.parameters)
    }
    
    func testRequestPropertiesLimit() throws {
        let changes = GetChangesOperation(databaseName: dbName!, limit: 4)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["limit":"4"], changes.parameters)
    }

    func testReuqestPropertiesSince() throws {
        let changes = GetChangesOperation(databaseName: dbName!, since: 0)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["since":"0"], changes.parameters)
    }
    
    func testRequestPropertiesStyle() throws {
        let changes = GetChangesOperation(databaseName: dbName!, style: .main)
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["style":"main_only"], changes.parameters)
    }
    
    func testRequestPropertiesView() throws {
        let changes = GetChangesOperation(databaseName: dbName!, view: "myView")
        XCTAssert(changes.validate())
        try changes.serialise()
        XCTAssertEqual("GET", changes.method)
        XCTAssertEqual(["view":"myView"], changes.parameters)
    }
    
}
