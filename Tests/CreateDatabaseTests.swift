//
//  CreateDatabaseTests.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
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


class CreateDatabaseTests : XCTestCase {
    
    
    let url :String = "http://localhost:5984"
    let username:String? = nil
    let password:String? = nil
    let dbName:String = "swift-cloudant-create-db-test" // should randomize do this later
    
    override func tearDown() {
        let client = CouchDBClient(url:NSURL(string: url)!,username:username,password:password)
        
        let delete = DeleteDatabaseOperation()
        delete.databaseName = self.dbName
        client.add(operation: delete)
        delete.waitUntilFinished()
        
        super.tearDown()
        
        
    }
    
    
    func testCreateUsingPut() {
        let createExpectation = self.expectation(withDescription:"create database")
        
        let client = CouchDBClient(url:NSURL(string: url)!,username:username,password:password)
        
        let create = CreateDatabaseOperation()
        create.databaseName = self.dbName
        create.createDatabaseCompletionHandler = {( statusCode, error) in
            createExpectation.fulfill()
            XCTAssertNotNil(statusCode)
            if let statusCode = statusCode {
                XCTAssertTrue(statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        
        client.add(operation:create)
        
        self.waitForExpectations(withTimeout:10.0, handler: nil)
    }

    
}