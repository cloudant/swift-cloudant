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
            let putDoc = PutDocumentOperation(id: UUID().uuidString.lowercased(), body: doc, databaseName: dbName) { response, httpInfo, error in
                XCTAssertNotNil(response)
                XCTAssertNotNil(httpInfo)
                XCTAssertNil(error)
            
            }
            client?.add(operation: putDoc).waitUntilFinished()
        }
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName, client: client!)
        
        super.tearDown()
        
        print("Deleted database: \(dbName)")
    }
    
    func createAllDocsOperation(descending: Bool? = true,
                                endKey: String? = "endKey",
                                includeDocs: Bool? = true,
                                conflicts: Bool? = true,
                                inclusiveEnd: Bool? = true,
                                keys: [String]? = ["keys", "keys"],
                                key: String? = nil,
                                skip: UInt? = 0,
                                limit: UInt? = 25,
                                startKey: String? = "startKey",
                                startKeyDocId: String? = "startKeyDocId",
                                endKeyDocId: String? = "endKeyDocId",
                                stale: Stale? = .ok,
                                updateSeq: Bool? = true,
                                rowHandler: (([String:Any]) -> Void) = { (doc) in
        // do nothing
        }
        ) -> GetAllDocsOperation {
        let allDocs = GetAllDocsOperation(databaseName: dbName,
                                          descending: descending,
                                          endKey: endKey,
                                          includeDocs: includeDocs,
                                          conflicts: conflicts,
                                          key: key,
                                          keys:keys,
                                          limit: limit,
                                          skip:skip,
                                          startKeyDocumentID: startKeyDocId,
                                          endKeyDocumentID: endKeyDocId,
                                          stale: stale,
                                          startKey: startKey,
                                          includeLastUpdateSequenceNumber: updateSeq,
                                          inclusiveEnd:inclusiveEnd,
                                          rowHandler: rowHandler
                                          )  { (response, httpInfo, error) in
                                                //do nothing.
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
    
    func testAllDocsValidationAllFieldsPresent(){
        let allDocs = createAllDocsOperation(key: "myKey")
        XCTAssertFalse(allDocs.validate())
    }
    
    func testValidationConfictsWithoutDocs(){
        let allDocs = GetAllDocsOperation(databaseName: dbName, conflicts: true)
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        XCTAssertEqual(expectedParams,
            allDocs.parameters)
        
    }
    
    func testGenerateRequestAscending() throws {
        let allDocs = createAllDocsOperation(descending: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "descending")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateReuqestWithoutEndKey() throws {
        let allDocs = createAllDocsOperation(endKey: nil)
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "endkey")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateReuqestWithoutDocs() throws {
        let allDocs = createAllDocsOperation(includeDocs: nil, conflicts:nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "include_docs")
        expectedParams.removeValue(forKey: "conflicts")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutConflicts() throws {
        let allDocs = createAllDocsOperation(conflicts: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "conflicts")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWitoutInclusiveEnd() throws {
        let allDocs = createAllDocsOperation(inclusiveEnd: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "inclusive_end")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutKey() throws {
        let allDocs = createAllDocsOperation(key: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "key")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutKeysWithKey() throws {
        let allDocs = createAllDocsOperation(keys: nil, key: "mykey")
        
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
        let allDocs = createAllDocsOperation(skip: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "skip")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutLimit() throws {
        let allDocs = createAllDocsOperation(limit: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "limit")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutStartKey() throws {
        let allDocs = createAllDocsOperation(startKey: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "startkey")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutStartKeyDocId() throws {
        let allDocs = createAllDocsOperation(startKeyDocId: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "startkey_docid")
        
        XCTAssertEqual(expectedParams,
            allDocs.parameters)
    }
    
    func testGenerateRequestWithoutEndKeyDocId() throws {
        let allDocs = createAllDocsOperation(endKeyDocId: nil)
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "endkey_docid")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestWithoutStale() throws {
        let allDocs = createAllDocsOperation(stale: nil)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams.removeValue(forKey: "stale")
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testGenerateRequestUpdateAfter() throws {
        let allDocs = createAllDocsOperation(stale: .updateAfter)
        
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
                let expected:[String:[String]] = ["keys":["keys","keys"]]
                XCTAssertEqual(expected as NSDictionary, requestData as NSDictionary)
                
            }
        }
        
        var expectedParams = self.expectedParams
        expectedParams["stale"] = "update_after"
        
        XCTAssertEqual(expectedParams,
                       allDocs.parameters)
    }
    
    func testEndToEndRequest() throws {
        let expectation = self.expectation(description: "AllDocs request")
        
                var docCount = 0
        
        let allDocs = GetAllDocsOperation(databaseName: dbName, rowHandler: { _ in
            docCount += 1
        }){ response, info, error in
        
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssertEqual(200, info.statusCode)
            }
            XCTAssertNotNil(response)
            expectation.fulfill()
        }
        
        client?.add(operation: allDocs)
        
        self.waitForExpectations(timeout: 10.0)
    }
    
    func testDocumentPayload(){
        let expectation = self.expectation(description: "AllDocs request")
        let rowHandler = self.expectation(description: "doc handler")
        
        let allDocs = GetAllDocsOperation(databaseName: dbName, rowHandler: { doc in
            let expected:[String:String] = ["hello":"world"]
            XCTAssertEqual(expected as NSDictionary, doc as NSDictionary)
            rowHandler.fulfill()
        }) { response, info, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssertEqual(200, info.statusCode)
            }
            XCTAssertNotNil(response)
            expectation.fulfill()
        }
        
        simulateOkResponseFor(operation: allDocs, jsonResponse: ["rows":[["hello":"world"]]])
        
        self.waitForExpectations(timeout: 10.0)
    }  

}
