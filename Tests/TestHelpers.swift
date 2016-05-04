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
        get {
            let defaultURL = "http://localhost:5984"
            if let url = TestSettings.getInstance().settings["TEST_COUCH_URL"] as? String {
                if url.isEmpty {
                    return defaultURL
                }
                return url
            } else {
                NSLog("Failed to get URL from config, defaulting to localhost")
                return defaultURL
            }
        }
    }
    
    var username:String? {
        get {
            let username = TestSettings.getInstance().settings["TEST_COUCH_USERNAME"] as? String
            if  username != nil && username!.isEmpty {
                return nil;
            } else {
                return username
            }
        }
    }
    
    var password:String? {
        get {
            let password =  TestSettings.getInstance().settings["TEST_COUCH_PASSWORD"] as? String
            if password != nil && password!.isEmpty {
                return nil
            } else {
                return password
            }
        }
        
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
    
    func deleteDatabase(databaseName: String, client: CouchDBClient) -> Void {
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
        client.add(operation: delete)
    }
}

extension Array where Element : NSURLQueryItem {
    
    /**
     Checks if this array is equivalent to another array. For an array to be equivalent to another
     they need to contain the same elements, however they do __not__ need to be in the same order.
     
     - parameter to: the `[NSURLQueryItem]` to compare to.
     */
    func isEquivalent(to:[NSURLQueryItem]) -> Bool {
        var to = to
        if(self.count != to.count){
            return false
        }
        
        for queryItem in self {
            if let index = to.index(of: queryItem) {
                to.remove(at: index)
            } else {
                return false
            }
        }
        return to.count == 0
    }
}

class TestSettings {
    
    private let settings: [String:AnyObject];
    private static var instance:TestSettings?
    
    private init() {
        let bundle = NSBundle(for: TestSettings.self)
        
        let testSettingsPath = bundle.pathForResource("TestSettings", ofType: "plist")
        
        if let testSettingsPath = testSettingsPath,
            let settingsDict = NSDictionary(contentsOfFile: testSettingsPath) as? [String:AnyObject] {
            settings = settingsDict
        } else {
            settings = [:]
        }
    }
    
    class func getInstance() -> TestSettings {
        if let instance = instance {
            return instance
        } else {
            instance = TestSettings()
            return instance!
        }
    }
}
