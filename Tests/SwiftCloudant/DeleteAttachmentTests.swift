//
//  DeleteAttachmentTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 17/05/2016.
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

class DeleteAttachmentTests : XCTestCase {
    
    var dbName: String? = nil
    var client: CouchDBClient? = nil
    let docId: String = "PutAttachmentTests"
    var revId: String?
    
    override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
        let createDoc = PutDocumentOperation()
        createDoc.body = createTestDocuments(count: 1).first
        createDoc.docId = docId
        createDoc.completionHandler = {[weak self] (response, info, error) in
            self?.revId = response?["rev"] as? String
        }
        createDoc.databaseName = dbName
        let nsCreate = Operation(couchOperation: createDoc)
        client?.add(operation: nsCreate)
        nsCreate.waitUntilFinished()
        
        let attachment = "This is my awesome essay attachment for my document"
        let put = PutAttachmentOperation()
        put.docId = docId
        put.revId = revId
        put.data = attachment.data(using: String.Encoding.utf8, allowLossyConversion: false)
        put.attachmentName = "myAwesomeAttachment"
        put.contentType = "text/plain"
        put.databaseName = dbName
        put.completionHandler = {[weak self] (response, info, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssert(info.statusCode / 100 == 2)
            }
            XCTAssertNotNil(response)
            self?.revId = response?["rev"] as? String
            
        }
        let nsPut = Operation(couchOperation: put)
        client?.add(operation: nsPut)
        nsPut.waitUntilFinished()
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        
        super.tearDown()
    }
    
    func testDeleteAttachment(){
        let deleteExpectation = self.expectation(withDescription: "Delete expectation")
        let delete = DeleteAttachmentOperation()
        delete.docId = docId
        delete.revId = revId
        delete.attachmentName = "myAwesomeAttachment"
        delete.databaseName = self.dbName
        delete.completionHandler = { (response, info, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssert(info.statusCode / 100 == 2)
            }
            XCTAssertNotNil(response)
            deleteExpectation.fulfill()
        }
        client?.add(operation: delete)
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testDeleteAttachmentValidationMissingId() {
        let delete = DeleteAttachmentOperation()
        delete.revId = revId
        delete.attachmentName = "myAwesomeAttachment"
        delete.databaseName = self.dbName
        XCTAssertFalse(delete.validate())
    }
    
    func testDeleteAttachmentValidationMissingRev() {
        let delete = DeleteAttachmentOperation()
        delete.docId = docId
        delete.attachmentName = "myAwesomeAttachment"
        delete.databaseName = self.dbName
        XCTAssertFalse(delete.validate())
    }
    
    func testDeleteAttachmentValidationMissingName() {
        let delete = DeleteAttachmentOperation()
        delete.docId = docId
        delete.revId = revId
        delete.databaseName = self.dbName
        XCTAssertFalse(delete.validate())
    }
    
    func testDeleteAttachmentHTTPOperationProperties(){
        let delete = DeleteAttachmentOperation()
        delete.docId = docId
        delete.revId = revId
        delete.attachmentName = "myAwesomeAttachment"
        delete.databaseName = self.dbName
        XCTAssertTrue(delete.validate())
        XCTAssertEqual(["rev": revId!], delete.parameters)
        XCTAssertEqual("/\(self.dbName!)/\(docId)/myAwesomeAttachment", delete.endpoint)
        XCTAssertEqual("DELETE", delete.method)
    }

}
