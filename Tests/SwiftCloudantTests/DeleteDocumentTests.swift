//
//  DeleteDocumentTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 12/04/2016.
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

class DeleteDocumentTests: XCTestCase {
    var dbName: String? = nil
    var client: CouchDBClient? = nil

    override func setUp() {
        super.setUp()

        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)

        print("Created database: \(dbName!)")
    }

    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }

    func testDocumentCanBeDeleted() {
        let expectation = self.expectation(description: "Delete document")
        
        let create = PutDocumentOperation(id: "testId",
                                        body: ["hello": "world"],
                                databaseName: dbName!){[weak self] (response, httpInfo, error) in
            
            let delete = DeleteDocumentOperation(id: response?["id"] as! String,
                                                 revision: response?["rev"] as! String,
                                                 databaseName: self!.dbName!)
            { (response, httpInfo, error) in
                expectation.fulfill()
                XCTAssertNotNil(httpInfo)
                if let httpInfo = httpInfo {
                    XCTAssert(httpInfo.statusCode / 100 == 2)
                }
                XCTAssertNil(error)
                XCTAssertEqual(true, response?["ok"] as? Bool)
            }
            self?.client?.add(operation: delete)

        }

        let nsCreate = Operation(couchOperation: create)
        
        client?.add(operation: nsCreate)

        self.waitForExpectations(timeout: 10.0, handler: nil)

    }

    func testDeleteDocumentOpCompletesWithoutCallback() {
        let expectation = self.expectation(description: "Delete document")
 
        let create = PutDocumentOperation(id: "testId",
                                        body: ["hello": "world"],
                                databaseName: dbName!) { [weak self](response, httpInfo, error) in
            
            let delete = DeleteDocumentOperation(id: response?["id"] as! String, revision: response!["rev"] as! String, databaseName: self!.dbName!)
            { [weak self](response, httpInfo, error) in
                XCTAssertNotNil(httpInfo)
                if let httpInfo = httpInfo {
                    XCTAssert(httpInfo.statusCode / 100 == 2)
                }
                XCTAssertNil(error)
                
                let get = GetDocumentOperation(id: "testId", databaseName: self!.dbName!)
                { (response, httpInfo, error) in
                    expectation.fulfill()
                    XCTAssertNotNil(response)
                    XCTAssertNotNil(error)
                }
                self?.client?.add(operation: get)
            }
            self?.client?.add(operation: delete)
            
        }



        client?.add(operation: create)

        self.waitForExpectations(timeout: 100.0, handler: nil)
    }
}
