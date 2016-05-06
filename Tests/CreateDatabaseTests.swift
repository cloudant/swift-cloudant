//
//  CreateDatabaseTests.swift
//  SwiftCloudant
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

    var dbName:String? = nil
    var client:CouchDBClient? = nil
    
    
    override func setUp() {
        super.setUp()
        self.dbName = generateDBName()
        client = CouchDBClient(url:NSURL(string: url)!,username:username,password:password)
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }
    
    
    func testCreateUsingPut() {
        let createExpectation = self.expectation(withDescription:"create database")
        

        
        let create = CreateDatabaseOperation()
        create.databaseName = self.dbName
        create.createDatabaseCompletionHandler = {(response, httpInfo, error) in
            createExpectation.fulfill()
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssertTrue(httpInfo.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        
        client?.add(operation:create)
        
        self.waitForExpectations(withTimeout:10.0, handler: nil)
    }

    
}