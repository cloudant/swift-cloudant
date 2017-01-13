//
//  GetAllDatabasesTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 23/05/2016.
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


public class GetAllDatabasesTest : XCTestCase {
    
    
    var dbName: String? = nil
    var client: CouchDBClient?
    
    override public func setUp() {
        super.setUp()
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
    }
    
    override public func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        super.tearDown()
    }
    
    public func testListAllDbs(){
        let expectation =  self.expectation(description: "all_dbs")
        var found = false
        let list = GetAllDatabasesOperation(databaseHandler:
        { (dbName) in
            if dbName.hasPrefix("_"){
                return
            }
            XCTAssertNotNil(dbName)
            if self.dbName! == dbName {
                found = true
            }
        })
        { (response, httpInfo, error ) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            if let response = response {
                let expected: [String] = [self.dbName!]
                
                if response is [String] {
                    XCTAssertTrue(expected.contains(self.dbName!))
                } else {
                    XCTFail("response is not an array [String]")
                }
                
            }
            
            expectation.fulfill()
        }
        client?.add(operation: list)
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssertTrue(found, "Did not find database \(self.dbName!) in a call to the database handler")
        
    }
    
    
}
