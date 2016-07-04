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
    
    var client: CouchDBClient? = nil;
    var dbName: String? = nil
    
    
    public override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string:self.url)!, username: self.username, password: self.password)
    }
    
    
    func testCanCreateTextIndexes() {
        let expectation = self.expectation(withDescription: "create text index")
        let index = CreateTextQueryIndexOperation()
        index.databaseName = dbName
        index.completionHandler = { (response, httpStatus, error) in
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpStatus)
            if let httpStatus = httpStatus {
                XCTAssert(httpStatus.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
            expectation.fulfill()
        }
        self.simulateOkResponseFor(operation: index)
        self.waitForExpectations(withTimeout:10.0, handler: nil)
    }
    
    func testCanCreateJSONIndexes() {
        let expectation = self.expectation(withDescription: "create json Index")
        let index = CreateJsonQueryIndexOperation()
        index.databaseName = dbName
        index.fields = [Sort(field:"foo", sort:nil)]
        index.completionHandler = { (response, httpStatus, error) in
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpStatus)
            if let httpStatus = httpStatus {
                XCTAssert(httpStatus.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
            expectation.fulfill()
        }
        self.simulateOkResponseFor(operation: index)
        self.waitForExpectations(withTimeout:10.0, handler: nil)
    }
    
    func testJsonIndexRequestProperties() throws {
        let index = CreateJsonQueryIndexOperation()
        index.fields = [Sort(field:"foo", sort:nil)]
        index.indexName = "indexName"
        index.designDoc = "ddoc"
        index.databaseName = "dbname"
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
            XCTAssertEqual(["type":"json", "index":["fields" : ["foo"]], "name" : "indexName", "ddoc":"ddoc"] as NSDictionary, json as? NSDictionary)
        }
        
    }
    
    func testTextIndexRequestProperties() throws {
        let index = CreateTextQueryIndexOperation()
        index.fields = [TextIndexField(name: "foo", type: .String)]
        index.indexName = "indexName"
        index.designDoc = "ddoc"
        index.defaultFieldAnalyzer = "english"
        index.defaultFieldEnabled = true
        index.selector = ["bar": "foo"]
        index.databaseName = "dbname"
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
            XCTAssertEqual(["type":"text", "index" : [ "selector": ["bar" : "foo"], "fields" : [["foo":"string"]], "default_field": ["enabled": true, "analyzer": "english" ]], "name" : "indexName", "ddoc":"ddoc"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    
    func testJsonValidationMissingFields(){
        let index = CreateJsonQueryIndexOperation()
        index.databaseName = "dbName"
        XCTAssertFalse(index.validate())
    }
    
    func testJsonEmitsPresentFieldsMissingIndexName() throws  {
        let index = CreateJsonQueryIndexOperation()
        index.fields = [Sort(field:"foo", sort:nil)]
        index.designDoc = "ddoc"
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"json", "index":["fields" : ["foo"]], "ddoc":"ddoc"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testJsonEmitsPresentFieldsMissingddoc() throws {
        let index = CreateJsonQueryIndexOperation()
        index.fields = [Sort(field:"foo", sort:nil)]
        index.indexName = "indexName"
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"json", "index":["fields" : ["foo"]], "name":"indexName"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingIndexName() throws {
        let index = CreateTextQueryIndexOperation()
        index.fields = [TextIndexField(name: "foo", type: .String)]
        index.designDoc = "ddoc"
        index.defaultFieldAnalyzer = "english"
        index.defaultFieldEnabled = true
        index.selector = ["bar": "foo"]
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"text", "index" : ["selector":["bar":"foo"], "fields" : [["foo":"string"]], "default_field": ["enabled": true, "analyzer": "english" ]], "ddoc":"ddoc"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingFields() throws {
        let index = CreateTextQueryIndexOperation()
        index.indexName = "indexName"
        index.designDoc = "ddoc"
        index.defaultFieldAnalyzer = "english"
        index.defaultFieldEnabled = true
        index.selector = ["bar": "foo"]
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"text", "name": "indexName", "index" : ["selector":["bar":"foo"], "default_field": ["enabled": true, "analyzer": "english" ]], "ddoc":"ddoc"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingddoc() throws {
        let index = CreateTextQueryIndexOperation()
        index.fields = [TextIndexField(name: "foo", type: .String)]
        index.indexName = "indexName"
        index.defaultFieldAnalyzer = "english"
        index.defaultFieldEnabled = true
        index.selector = ["bar": "foo"]
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"text", "index" : ["selector":["bar":"foo"], "fields" : [["foo":"string"]], "default_field": ["enabled": true, "analyzer": "english" ]], "name":"indexName"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissinganalyzer() throws {
        let index = CreateTextQueryIndexOperation()
        index.fields = [TextIndexField(name: "foo", type: .String)]
        index.designDoc = "ddoc"
        index.indexName = "indexName"
        index.defaultFieldEnabled = true
        index.selector = ["bar": "foo"]
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"text", "index" : ["selector":["bar":"foo"], "fields" : [["foo":"string"]], "default_field": ["enabled": true ]], "ddoc":"ddoc", "name": "indexName"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingDefaultFieldEnabled() throws {
        let index = CreateTextQueryIndexOperation()
        index.fields = [TextIndexField(name: "foo", type: .String)]
        index.designDoc = "ddoc"
        index.defaultFieldAnalyzer = "english"
        index.indexName = "indexName"
        index.selector = ["bar": "foo"]
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"text", "index" : [ "selector":["bar":"foo"],"fields" : [["foo":"string"]], "default_field": ["analyzer": "english" ]], "ddoc":"ddoc", "name": "indexName"] as NSDictionary, json as? NSDictionary)
        }
    }
    
    func testTextIndexEmitsPresentFieldsMissingselector() throws {
        let index = CreateTextQueryIndexOperation()
        index.fields = [TextIndexField(name: "foo", type: .String)]
        index.indexName = "indexName"
        index.designDoc = "ddoc"
        index.defaultFieldAnalyzer = "english"
        index.defaultFieldEnabled = true
        index.databaseName = "dbname"
        XCTAssert(index.validate())
        try index.serialise()
        // do the json manipulation stuff.
        let data = index.data
        
        XCTAssertNotNil(data)
        if let data = data {
            let json = try JSONSerialization.jsonObject(with: data)
            XCTAssertEqual(["type":"text", "index" : [ "fields" : [["foo":"string"]], "default_field": ["enabled": true, "analyzer": "english" ]],"name":"indexName", "ddoc":"ddoc"] as NSDictionary, json as? NSDictionary)
        }
    }
    
}
