//
//  FindDocumentOperationTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 20/04/2016.
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

import XCTest
@testable import SwiftCloudant

class FindDocumentOperationTests: XCTestCase {
    var client: CouchDBClient? = nil;
    var dbName: String? = nil
    let response = [    "docs" : [
        [
            "_id" : "2",
            "_rev" : "1-9f0e70c7592b2e88c055c51afc2ec6fd",
            "foo" : "test",
            "bar" : 2600000
        ],
        [
            "_id" : "1",
            "_rev" : "1-026418c17a353a9b73a6ccac19c142a4",
            "foo" : "another test",
            "bar" : 9800000
        ]
        ]]
    
    
    override func setUp() {
        super.setUp()
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string:self.url)!, username: self.username, password: self.password)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    
    func testInvalidSelector() {
        

        let expectation = self.expectation(description: "invalidSelector")
        
        let find = FindDocumentsOperation(selector: ["foo": client!], databaseName: dbName!)
        { (response, httpInfo, error) in
            XCTAssertNil(response)
            XCTAssertNil(httpInfo)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        client?.add(operation: find)
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
        
    }
    
    func testCanQueryDocsOnlySelector() {
        
        
        let firstDocExpectation = self.expectation(description: "1st Doc result")
        let secondDocExpectation = self.expectation(description: "2nd doc result")
        let operationComplete = self.expectation(description: "Operation Complete")
        
        var first = true
        let find = FindDocumentsOperation(selector: ["foo":"bar"], databaseName: dbName!,
                                          documentFoundHandler: {(document) in
            if first {
                first = false
                firstDocExpectation.fulfill()
            } else {
                secondDocExpectation.fulfill()
            }
            
            XCTAssertNotNil(document)
            // Assert that each document contains 4 JSON properties.
            XCTAssertEqual(4, document.count)
        }){ (response, httpInfo, error) in
            XCTAssertNotNil(response)
            XCTAssertNil(response?["bookmark"])
            XCTAssertNotNil(httpInfo)
            XCTAssertNil(error)
            operationComplete.fulfill()
            
        }
        
        self.simulateOkResponseFor(operation: find, jsonResponse: JSONResponse(dictionary: response))
        
        self.waitForExpectations(timeout: 10.0, handler: nil)

    }
    
    func testCanQueryDocsAllValuesSet() {
        let expectation = self.expectation(description: "Find op with all the options")
        
        let find = FindDocumentsOperation(selector: ["foo":"bar"], databaseName: dbName!,
                                          fields:["foo","bar"],
                                          limit: 26,
                                          skip: 1,
                                          sort: [Sort(field: "foo", sort: nil)],
                                          bookmark: "blah",
                                          useIndex: "anIndex",
                                          r: 1)
        { (response, httpInfo, error) in
            XCTAssertNotNil(response)
            XCTAssertNil(response?["bookmark"])
            XCTAssertNotNil(httpInfo)
            XCTAssertNil(error)
            expectation.fulfill()
            
        }
        
        self.simulateOkResponseFor(operation: find, jsonResponse: JSONResponse(dictionary: response))
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testOperationRequestPayload() throws {
        let find = FindDocumentsOperation(selector: ["foo":"bar"], databaseName: dbName!,
                                          fields:["foo","bar"],
                                          limit: 26,
                                          skip: 1,
                                          sort: [Sort(field: "foo", sort: nil)],
                                          bookmark: "blah",
                                          useIndex: "anIndex",
                                          r: 1)
        
        
        XCTAssert(find.validate())
        try find.serialise()
        XCTAssertEqual("/\(dbName!)/_find", find.endpoint)
        XCTAssertEqual("POST", find.method)
        let httpBodyOpt = find.data
        XCTAssertNotNil(httpBodyOpt)
        
        if let httpBody = httpBodyOpt {
        
            do {
                let json = try JSONSerialization.jsonObject(with: httpBody, options: JSONSerialization.ReadingOptions()) as? [String:NSObject]
                
                let expected:[String:NSObject] = ["selector":["foo":"bar"],
                                "fields":["foo","bar"],
                                "limit": 26,
                                "skip": 1,
                                "sort": ["foo"],
                                "bookmark": "blah",
                                "use_index":"anIndex",
                                "r": 1
                                ]
                
                if let json = json {
                    XCTAssertEqual(expected , json, "Expected: \(expected) but was \(json)")
               } else {
                   XCTFail("Json could not be deseralised to the type [String:AnyObject]")
                }
            
            } catch {
                XCTFail("Error deserialising json: \(error)")
            }
        }
    }
    
    func testOperationRequestWithSortDirectionAsc() throws {
        let find = FindDocumentsOperation(selector: ["foo":"bar"], databaseName: dbName!,
                                          sort:[Sort(field: "foo", sort: .asc)])
        
        
        XCTAssert(find.validate())
        try find.serialise()
        XCTAssertEqual("/\(dbName!)/_find", find.endpoint)
        XCTAssertEqual("POST", find.method)
        let httpBodyOpt = find.data
        XCTAssertNotNil(httpBodyOpt)
        
        if let httpBody = httpBodyOpt {
            
            do {
                let json = try JSONSerialization.jsonObject(with: httpBody, options: JSONSerialization.ReadingOptions()) as? [String:NSObject]
                
                let expected:[String:NSObject] = ["selector":["foo":"bar"],
                                                  "sort": [["foo":"asc"]],
                ]
                
                if let json = json {
                    XCTAssertEqual(expected , json, "Expected: \(expected) but was \(json)")
                } else {
                    XCTFail("Json could not be deseralised to the type [String:AnyObject]")
                }
                
            } catch {
                XCTFail("Error deserialising json: \(error)")
            }
        }
    }
    
    func testOperationRequestWithSortDirectionDesc() throws {
        let find = FindDocumentsOperation(selector: ["foo":"bar"], databaseName: dbName!,
                                          sort:[Sort(field: "foo", sort: .desc)])
        
        
        XCTAssert(find.validate())
        try find.serialise()
        XCTAssertEqual("/\(dbName!)/_find", find.endpoint)
        XCTAssertEqual("POST", find.method)
        let httpBodyOpt = find.data
        XCTAssertNotNil(httpBodyOpt)
        
        if let httpBody = httpBodyOpt {
            
            do {
                let json = try JSONSerialization.jsonObject(with: httpBody, options: JSONSerialization.ReadingOptions()) as? [String:NSObject]
                
                let expected:[String:NSObject] = ["selector":["foo":"bar"],
                                                  "sort": [["foo":"desc"]],
                                                  ]
                
                if let json = json {
                    XCTAssertEqual(expected , json, "Expected: \(expected) but was \(json)")
                } else {
                    XCTFail("Json could not be deseralised to the type [String:AnyObject]")
                }
                
            } catch {
                XCTFail("Error deserialising json: \(error)")
            }
        }
    }
    
    func testBookmarkReturnedFromTextQuery() {
        let expectation = self.expectation(description: "Find op with all the options")
        let find = FindDocumentsOperation(selector: ["foo":"bar"], databaseName: dbName!,
                                          fields:["foo","bar"],
                                          limit: 26,
                                          skip: 1,
                                          sort: [Sort(field: "foo", sort: nil)],
                                          bookmark: "blah",
                                          useIndex: "anIndex",
                                          r: 1)
        { (response, httpInfo, error) in
            XCTAssertNotNil(response)
            XCTAssertEqual("blah", response?["bookmark"] as? String)
            XCTAssertNotNil(httpInfo)
            XCTAssertNil(error)
            expectation.fulfill()
            
        }
        
        self.simulateOkResponseFor(operation: find, jsonResponse: ["bookmark":"blah", "docs":[]])
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testValuesOmittedIfNotSet() throws {
        let find = FindDocumentsOperation(selector: ["foo":"bar"], databaseName: dbName!)
        XCTAssert(find.validate())
        try find.serialise()
        

        
        XCTAssertEqual("/\(dbName!)/_find", find.endpoint)
        XCTAssertEqual("POST", find.method);
        let httpBodyOpt = find.data
        XCTAssertNotNil(httpBodyOpt)
        
        if let httpBody = httpBodyOpt {
            
            do {
                let json = try JSONSerialization.jsonObject(with: httpBody, options: JSONSerialization.ReadingOptions()) as? [String:NSObject]
                
                let expected:[String:NSObject] = ["selector":["foo":"bar"]]
                
                if let json = json {
                    XCTAssertEqual(expected , json, "Expected: \(expected) but was \(json)")
                } else {
                    XCTFail("Json could not be deseralised to the type [String:AnyObject]")
                }
                
            } catch {
                XCTFail("Error deserialising json: \(error)")
            }
        }
        
        
        
        
        
        
    }

}
