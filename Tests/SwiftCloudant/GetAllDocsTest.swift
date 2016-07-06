//
//  GetAllDocsTest.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 05/07/2016.
//  Copyright © 2016 IBM. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//


import XCTest
@testable import SwiftCloudant

class GetAllDocsTest: XCTestCase {

    lazy var dbName: String = { return self.generateDBName()}()
    var client: CouchDBClient? = nil
    
    override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName, client: client!)
        for doc in createTestDocuments(count: 10) {
            let putDoc = PutDocumentOperation()
            putDoc.databaseName = dbName
            putDoc.body = doc
            client?.add(operation: putDoc)
        }
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName, client: client!)
        
        super.tearDown()
        
        print("Deleted database: \(dbName)")
    }
    
    func createAllDocsOperation() -> GetAllDocsOperation {
        let allDocs = GetAllDocsOperation()
        allDocs.databaseName = dbName
        allDocs.descending = true
        allDocs.endKey = "endKey"
        allDocs.includeDocs = true
        allDocs.conflicts = true
        allDocs.inclusiveEnd = true
        allDocs.keys = ["keys","keys"]
        allDocs.skip = 0
        allDocs.limit = 25
        allDocs.startKey = "startKey"
        allDocs.startKeyDocId = "startKeyDocId"
        allDocs.endKeyDocId = "endKeyDocId"
        allDocs.stale = .Ok
        allDocs.updateSeq = true
        
        allDocs.completionHandler = { (response, httpInfo, error) in
            //do nothing.
        }
        allDocs.rowHandler = { (doc) in
            // do nothing
        }

        return allDocs
    }
    
    var expectedParams: [String: String] {
        return ["descending":"true",
                "endkey":"\"endKey\"",
                "include_docs":"true",
                "conflicts":"true",
                "inclusive_end": "true",
                "skip": "0",
                "limit": "25",
                "startkey": "\"startKey\"",
                "stale": "ok",
                "endkey_docid": "endKeyDocId",
                "startkey_docid": "startKeyDocId",
                "update_seq": "true"]
    }
    
    func testAllDocsValidationMissingDBName(){
        let allDocs = GetAllDocsOperation()
        allDocs.completionHandler = { (response, httpInfo, error) in
            //do nothing.
        }
        allDocs.rowHandler = { (doc) in
            // do nothing
        }
        XCTAssertFalse(allDocs.validate())
    }
    
    func testAllDocsValidationAllFieldsPresent(){
        let allDocs = createAllDocsOperation()
        allDocs.key = "myKey"
        
        allDocs.completionHandler = { (response, httpInfo, error) in
            //do nothing.
        }
        allDocs.rowHandler = { (doc) in
            // do nothing
        }
        XCTAssertFalse(allDocs.validate())
    }
    
    func testValidationConfictsWithoutDocs(){
        let allDocs = GetAllDocsOperation()
        allDocs.databaseName = dbName
        allDocs.conflicts = true
        XCTAssertFalse(allDocs.validate())
    }
    
    func testGenerateCorrectRequestAllOptions() throws {
        let allDocs = createAllDocsOperation()
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        XCTAssertEqual(expectedParams,
            allDocs.parameters)
        
    }
    
    func testGenerateRequestAscending() throws {
        let allDocs = createAllDocsOperation()
        allDocs.descending = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "descending")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateReuqestWithoutEndKey() throws {
        let allDocs = createAllDocsOperation()
        allDocs.endKey = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "endkey")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateReuqestWithoutDocs() throws {
        let allDocs = createAllDocsOperation()
        allDocs.includeDocs = nil
        allDocs.conflicts = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "include_docs")
        expectedParams.removeValue(forKey: "conflicts")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutConflicts() throws {
        let allDocs = createAllDocsOperation()
        allDocs.conflicts = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "conflicts")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWitoutInclusiveEnd() throws {
        let allDocs = createAllDocsOperation()
        allDocs.inclusiveEnd = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "inclusive_end")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutKey() throws {
        let allDocs = createAllDocsOperation()
        allDocs.key = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "key")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutKeysWithKey() throws {
        let allDocs = createAllDocsOperation()
        allDocs.keys = nil
        allDocs.key = "mykey"
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("GET", allDocs.method)
        XCTAssertNil(allDocs.data)
        
        var expectedParams = self.expectedParams
        expectedParams["key"] = "\"mykey\""
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutSkip() throws {
        let allDocs = createAllDocsOperation()
        allDocs.skip = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "skip")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutLimit() throws {
        let allDocs = createAllDocsOperation()
        allDocs.limit = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "limit")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutStartKey() throws {
        let allDocs = createAllDocsOperation()
        allDocs.startKey = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "startkey")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutStartKeyDocId() throws {
        let allDocs = createAllDocsOperation()
        allDocs.startKeyDocId = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "startkey_docid")
        
        XCTAssertEqual(expectedParams,
            allDocs.parameters)
    }
    
    func testGenerateRequestWithoutEndKeyDocId() throws {
        let allDocs = createAllDocsOperation()
        allDocs.endKeyDocId = nil
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "endkey_docid")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutStale() throws {
        let allDocs = createAllDocsOperation()
        allDocs.stale = nil
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "stale")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestUpdateAfter() throws {
        let allDocs = createAllDocsOperation()
        allDocs.stale = .UpdateAfter
        
        XCTAssert(allDocs.validate())
        try allDocs.serialise()
        
        XCTAssertEqual("POST", allDocs.method)
        XCTAssertEqual("/\(dbName)/_all_docs", allDocs.endpoint)
        
        let data = allDocs.data
        XCTAssertNotNil(data)
        
        if let data = data {
            let requestData = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            if let requestData = requestData {
                XCTAssertNotNil(requestData)
                XCTAssertEqual(["keys":["keys","keys"]], requestData)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams["stale"] = "update_after"
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testEndToEndRequest() throws {
        let expectation = self.expectation(withDescription: "AllDocs request")
        
        let allDocs = GetAllDocsOperation();
        allDocs.databaseName = dbName
        var docCount = 0
        allDocs.rowHandler = { _ in
            docCount += 1
        }
        allDocs.completionHandler = { response, info, error in
        
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssertEqual(200, info.statusCode)
            }
            XCTAssertNotNil(response)
            expectation.fulfill()
        }
        
        client?.add(operation: allDocs)
        
        self.waitForExpectations(withTimeout: 10.0)
    }
    
    func testDocumentPayload(){
        let expectation = self.expectation(withDescription: "AllDocs request")
        let rowHandler = self.expectation(withDescription: "doc handler")
        
        let allDocs = GetAllDocsOperation();
        allDocs.databaseName = dbName
        
        allDocs.rowHandler = { doc in
            XCTAssertEqual(["hello": "world"] as NSDictionary, doc)
            rowHandler.fulfill()
        }
        allDocs.completionHandler = { response, info, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssertEqual(200, info.statusCode)
            }
            XCTAssertNotNil(response)
            expectation.fulfill()
        }
        
        simulateOkResponseFor(operation: allDocs, jsonResponse: ["rows":[["hello":"world"]]])
        
        self.waitForExpectations(withTimeout: 10.0)
    }  

}
