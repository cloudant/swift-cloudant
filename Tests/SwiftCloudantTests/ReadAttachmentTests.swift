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
    
    static var allTests = {
        return [
            ("testReadAttachment", testReadAttachment),
            ("testReadAttachmentProperties", testReadAttachmentProperties)]
    }()
    
    var dbName: String? = nil
    var client: CouchDBClient? = nil
    let docId: String = "PutAttachmentTests"
    var revId: String?
    
    let attachment = "This is my awesome essay attachment for my document"
    let attachmentName = "myAwesomeAttachment"
    
    override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
        let createDoc = PutDocumentOperation(id: docId, body: createTestDocuments(count: 1).first!, databaseName: dbName!) {[weak self] (response, info, error) in
            self?.revId = response?["rev"] as? String
        }
        client?.add(operation: createDoc).waitUntilFinished()
        
        
        let put = PutAttachmentOperation(name: attachmentName, contentType: "text/plain", data: attachment.data(using: String.Encoding.utf8, allowLossyConversion: false)!,
            documentID: docId,
            revision: revId!,
            databaseName: dbName!
        ) {[weak self] (response, info, error) in
            self?.revId = response?["rev"] as? String
        }
        client?.add(operation: put).waitUntilFinished()
    }
    
    override func tearDown() { 
        deleteDatabase(databaseName: dbName!, client: client!)
        
        super.tearDown()
    }
    
    func testReadAttachment() {
        let expectation = self.expectation(description: "read attachment")
        let read = ReadAttachmentOperation(name: attachmentName, documentID: docId, databaseName: dbName!) {[weak self] (data, info, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssert(info.statusCode / 100 == 2)
            }
            
            XCTAssertNotNil(data)
            if let data = data {
                let attxt = String(data: data, encoding: .utf8)
                XCTAssertEqual(self?.attachment, attxt)
            }
            
            expectation.fulfill()
        }
        client?.add(operation: read)
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testReadAttachmentProperties() {
        let read = ReadAttachmentOperation(name: attachmentName, documentID: docId, revision: revId, databaseName: dbName!)
        XCTAssert(read.validate())
        XCTAssertEqual("GET", read.method)
        XCTAssertEqual("/\(dbName!)/\(docId)/\(attachmentName)", read.endpoint)
        XCTAssertEqual(["rev": revId!], read.parameters)
        XCTAssertNil(read.data)
    }
    
}
