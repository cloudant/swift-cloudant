//
//  TestHelpers.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 21/04/2016.
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

// Extension to add functions for commonly used operations in tests.
extension XCTestCase {
    
    var url:String {
        return "http://localhost:5984"
    }
    
    var username:String? {
        return nil
    }
    
    var password:String? {
        return nil
    }
    
    
    func createTestDocuments(count: Int) -> [[String:AnyObject]] {
        var docs = [[String:AnyObject]]()
        for _ in 1...count {
            docs.append(["data": NSUUID().uuidString.lowercased()])
        }
        
        return docs
    }
    
    func generateDBName() -> String {
        return "a-\(NSUUID().uuidString.lowercased())"
    }
    
    func createDatabase(databaseName:String, client:CouchDBClient) -> Void {
        let create = CreateDatabaseOperation()
        create.databaseName = databaseName;
        create.createDatabaseCompletionHandler = {(statusCode, error) in
            if let statusCode = statusCode {
                XCTAssert(statusCode / 100 == 2)
            } else {
                XCTAssertNotNil(statusCode)
            }
            XCTAssertNil(error)
        }
        client.add(operation: create)
        create.waitUntilFinished()
    }
    
    func deleteDatabase(databaseName:String, client:CouchDBClient) -> Void {
        let delete = DeleteDatabaseOperation()
        delete.databaseName = databaseName
        delete.deleteDatabaseCompletionHandler = {(statusCode, error) in
            if let statusCode = statusCode {
                XCTAssert(statusCode / 100 == 2)
            } else {
                XCTAssertNotNil(statusCode)
            }
            XCTAssertNil(error)
        }
    }
}
