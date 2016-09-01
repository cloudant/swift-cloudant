//
//  CreateQueryIndexTests.swift
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


public class CreateQueryIndexTests : XCTestCase {
    
    static var allTests = {
        return [
            ("testCanCreateTextIndexes", testCanCreateTextIndexes),
            ("testCanCreateJSONIndexes",testCanCreateJSONIndexes),
            ("testJsonIndexRequestProperties",testJsonIndexRequestProperties),
            ("testTextIndexRequestProperties",testTextIndexRequestProperties),
            ("testJsonEmitsPresentFieldsMissingIndexName",testJsonEmitsPresentFieldsMissingIndexName),
            ("testJsonEmitsPresentFieldsMissingddoc", testJsonEmitsPresentFieldsMissingddoc),
            ("testTextIndexEmitsPresentFieldsMissingIndexName", testTextIndexEmitsPresentFieldsMissingIndexName),
            ("testTextIndexEmitsPresentFieldsMissingFields", testTextIndexEmitsPresentFieldsMissingFields),
            ("testTextIndexEmitsPresentFieldsMissingddoc", testTextIndexEmitsPresentFieldsMissingddoc),
            ("testTextIndexEmitsPresentFieldsMissingddoc",testTextIndexEmitsPresentFieldsMissingddoc),
            ("testTextIndexEmitsPresentFieldsMissingDefaultFieldEnabled", testTextIndexEmitsPresentFieldsMissingDefaultFieldEnabled),
            ("testTextIndexEmitsPresentFieldsMissingDefaultFieldEnabled",testTextIndexEmitsPresentFieldsMissingDefaultFieldEnabled)]
    }()
    
    var client: CouchDBClient? = nil;
    var dbName: String? = nil
    
    
    public override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string:self.url)!, username: self.username, password: self.password)
    }
    
    
    func testCanCreateTextIndexes() {
        let expectation = self.expectation(description: "create text index")
        let index = CreateTextQueryIndexOperation(databaseName: dbName!) { (response, httpStatus, error) in
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpStatus)
            if let httpStatus = httpStatus {
                XCTAssert(httpStatus.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
            expectation.fulfill()
        }
        self.simulateOkResponseFor(operation: index)
        self.waitForExpectations(timeout:10.0, handler: nil)
    }
    
    func testCanCreateJSONIndexes() {
        let expectation = self.expectation(description: "create json Index")
        let index = CreateJSONQueryIndexOperation(databaseName: dbName!, fields: [Sort(field:"foo", sort:nil)]) { (response, httpStatus, error) in
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpStatus)
            if let httpStatus = httpStatus {
                XCTAssert(httpStatus.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
            expectation.fulfill()
        }
        self.simulateOkResponseFor(operation: index)
        self.waitForExpectations(timeout:10.0, handler: nil)
    }
    
    func testJsonIndexRequestProperties() throws {
        let index = CreateJSONQueryIndexOperation(databaseName: "dbname", designDocumentID: "ddoc", name: "indexName", fields: [Sort(field:"foo", sort:nil)])
        XCTAssert(index.validate())
        try index.serialise()
        XCTAssertEqual("POST", index.method)
        XCTAssertEqual("/dbname/_index", index.endpoint)
        XCTAssertEqual([:], index.parameters)
        
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let expected: [String :Any] = ["type":"json", "index":["fields" : ["foo"]], "name" : "indexName", "ddoc":"ddoc"]
            XCTAssertEqual(expected as NSDictionary , json as? NSDictionary)
        }
        
    }
    
    func testTextIndexRequestProperties() throws {
        let index = CreateTextQueryIndexOperation(databaseName: "dbname", name: "indexName", fields:[TextIndexField(name: "foo", type: .string)], defaultFieldAnalyzer: "english", defaultFieldEnabled: true, selector: ["bar": "foo"], designDocumentID: "ddoc")
        XCTAssert(index.validate())
        try index.serialise()
        XCTAssertEqual("POST", index.method)
        XCTAssertEqual("/dbname/_index", index.endpoint)
        XCTAssertEqual([:], index.parameters)
        
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let defaultField: [String: Any] = ["enabled": true, "analyzer": "english" ]
            let index: [String: Any] =   [ "selector": ["bar" : "foo"], "fields" : [["foo":"string"]], "default_field": defaultField]
            let expected: [String :Any] = ["type":"text","index": index, "name" : "indexName", "ddoc":"ddoc"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testJsonEmitsPresentFieldsMissingIndexName() throws  {
        let index = CreateJSONQueryIndexOperation(databaseName: dbName!, designDocumentID: "ddoc", fields: [Sort(field:"foo", sort:nil)])
        XCTAssert(index.validate())
        try index.serialise()
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let expected: [String: Any] = ["type":"json", "index":["fields" : ["foo"]], "ddoc":"ddoc"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testJsonEmitsPresentFieldsMissingddoc() throws {
        let index = CreateJSONQueryIndexOperation(databaseName: dbName!, name: "indexName", fields: [Sort(field:"foo", sort:nil)])
        XCTAssert(index.validate())
        try index.serialise()
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let expected: [String: Any] = ["type":"json", "index":["fields" : ["foo"]], "name":"indexName"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingIndexName() throws {
        let index = CreateTextQueryIndexOperation(databaseName: "dbname", fields: [TextIndexField(name: "foo", type: .string)], defaultFieldAnalyzer: "english", defaultFieldEnabled: true, selector: ["bar": "foo"], designDocumentID: "ddoc")
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let defaultField: [String:Any] = ["enabled": true, "analyzer": "english" ]
            let index: [String: Any] = ["selector":["bar":"foo"], "fields" : [["foo":"string"]], "default_field": defaultField ]
            let expected: [String: Any] = ["type":"text", "index" : index , "ddoc":"ddoc"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingFields() throws {
        let index = CreateTextQueryIndexOperation(databaseName: "dbname", name: "indexName", defaultFieldAnalyzer: "english", defaultFieldEnabled: true, selector: ["bar": "foo"], designDocumentID: "ddoc")
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let defaultIndex:[String:Any] = ["enabled": true, "analyzer": "english" ]
            let index: [String: Any] = ["selector":["bar":"foo"], "default_field":defaultIndex ]
            let expected: [String: Any] = ["type":"text", "name": "indexName", "index" :index , "ddoc":"ddoc"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingddoc() throws {
        let index = CreateTextQueryIndexOperation(databaseName: "dbname", name: "indexName", fields: [TextIndexField(name: "foo", type: .string)], defaultFieldAnalyzer: "english", defaultFieldEnabled: true, selector: ["bar": "foo"]);
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let defaultField: [String:Any] = ["enabled": true, "analyzer": "english" ]
            let index: [String:Any]  = ["selector":["bar":"foo"], "fields" : [["foo":"string"]], "default_field": defaultField ]
            let expected: [String:Any] = ["type":"text", "index" :index , "name":"indexName"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissinganalyzer() throws {
        let index = CreateTextQueryIndexOperation(databaseName: "dbname", name: "indexName", fields: [TextIndexField(name: "foo", type: .string)], defaultFieldEnabled: true, selector: ["bar": "foo"], designDocumentID: "ddoc")
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let index: [String:Any] = ["selector":["bar":"foo"], "fields" : [["foo":"string"]], "default_field": ["enabled": true ]]
            let expected: [String: Any] = ["type":"text", "index" : index, "ddoc":"ddoc", "name": "indexName"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingDefaultFieldEnabled() throws {
        let index = CreateTextQueryIndexOperation(databaseName: "dbname", name: "indexName", fields: [TextIndexField(name: "foo", type: .string)], defaultFieldAnalyzer: "english", selector: ["bar": "foo"], designDocumentID: "ddoc")
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let index: [String: Any] = [ "selector":["bar":"foo"],"fields" : [["foo":"string"]], "default_field": ["analyzer": "english" ]]
            let expected: [String: Any] = ["type":"text", "index" : index, "ddoc":"ddoc", "name": "indexName"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingselector() throws {
        let index = CreateTextQueryIndexOperation(databaseName: "dbname", name: "indexName", fields: [TextIndexField(name: "foo", type: .string)], defaultFieldAnalyzer: "english", defaultFieldEnabled: true, designDocumentID: "ddoc")
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            let defaultField:[String: Any] = ["enabled": true, "analyzer": "english" ]
            let index: [String: Any] = [ "fields" : [["foo":"string"]], "default_field": defaultField ]
            let expected: [String: Any] = ["type":"text", "index" : index,"name":"indexName", "ddoc":"ddoc"]
            XCTAssertEqual(expected as NSDictionary, json as? NSDictionary)
        }
    }
    
}
