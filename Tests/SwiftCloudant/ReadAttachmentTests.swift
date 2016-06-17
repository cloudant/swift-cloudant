//
//  ReadAttachmentTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 02/06/2016.
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


import Foundation
import XCTest
@testable import SwiftCloudant

class ReadAttachmentTests: XCTestCase {
    
    var dbName: String? = nil
    var client: CouchDBClient? = nil
    let docId: String = "PutAttachmentTests"
    var revId: String?
    
    let attachment = "This is my awesome essay attachment for my document"
    let attachmentName = "myAwesomeAttachment"
    
    override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: NSURL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
        let createDoc = PutDocumentOperation()
        createDoc.body = createTestDocuments(count: 1).first
        createDoc.docId = docId
        createDoc.completionHandler = {[weak self] (response, info, error) in
            self?.revId = response?["rev"] as? String
        }
        createDoc.databaseName = dbName
        client?.add(operation: createDoc).waitUntilFinished()
        
        
        let put = PutAttachmentOperation()
        put.docId = docId
        put.revId = revId
        put.data = attachment.data(using: NSUTF8StringEncoding, allowLossyConversion: false)
        put.attachmentName = attachmentName
        put.contentType = "text/plain"
        put.completionHandler = {[weak self] (response, info, error) in
            self?.revId = response?["rev"] as? String
        }
        put.databaseName = dbName
        client?.add(operation: put).waitUntilFinished()
    }
    
    override func tearDown() { 
        deleteDatabase(databaseName: dbName!, client: client!)
        
        super.tearDown()
    }
    
    func testReadAttachment() {
        let expectation = self.expectation(withDescription: "read attachment")
        let read = ReadAttachmentOperation()
        read.docId = docId
        read.revId = revId
        read.attachmentName = attachmentName
        read.completionHandler = {[weak self] (data, info, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssert(info.statusCode / 100 == 2)
            }
            
            XCTAssertNotNil(data)
            if let data = data {
                let attxt = NSString(data: data, encoding: NSUTF8StringEncoding)
                XCTAssertEqual(self?.attachment, attxt)
            }
            
            expectation.fulfill()
        }
        read.databaseName = dbName
        client?.add(operation: read)
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testReadAttachmentProperties() {
        let read = ReadAttachmentOperation()
        read.docId = docId
        read.revId = revId
        read.attachmentName = attachmentName
        read.databaseName = dbName
        XCTAssert(read.validate())
        XCTAssertEqual("GET", read.method)
        XCTAssertEqual("/\(dbName!)/\(docId)/\(attachmentName)", read.endpoint)
        XCTAssertEqual(["rev": revId!], read.parameters)
        XCTAssertNil(read.data)
    }
    
    func testReadAttachmentValidationMissingDocId() {
        let read = ReadAttachmentOperation()
        read.revId = revId
        read.attachmentName = attachmentName
        read.databaseName = dbName
        XCTAssertFalse(read.validate())
    }
    
    func testReadAttachmentValidationMissingRevId() {
        let read = ReadAttachmentOperation()
        read.docId = docId
        read.attachmentName = attachmentName
        read.databaseName = dbName
        XCTAssertFalse(read.validate())
    }
    
    func testReadAttachmentValidationMissingAttachmentName() {
        let read = ReadAttachmentOperation()
        read.docId = docId
        read.revId = revId
        read.databaseName = dbName
        XCTAssertFalse(read.validate())
    }
    
    func testReadAttachmentValidationMissingdbName() {
        let read = ReadAttachmentOperation()
        read.docId = docId
        read.revId = revId
        read.attachmentName = attachmentName
        XCTAssertFalse(read.validate())
    }
    
    
}