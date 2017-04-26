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

import Dispatch
import Foundation
import XCTest
@testable import SwiftCloudant

// Extension to add functions for commonly used operations in tests.
extension XCTestCase {
    

    var url: String {
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

    var username: String? {
        get {
            let username = TestSettings.getInstance().settings["TEST_COUCH_USERNAME"] as? String
            if username != nil && username!.isEmpty {
                return nil;
            } else {
                return username
            }
        }
    }

    var password: String? {
        get {
            let password = TestSettings.getInstance().settings["TEST_COUCH_PASSWORD"] as? String
            if password != nil && password!.isEmpty {
                return nil
            } else {
                return password
            }
        }

    }

    func createTestDocuments(count: Int) -> [[String: Any]] {
        var docs = [[String: Any]]()
        for _ in 1 ... count {
            docs.append(["data": NSUUID().uuidString.lowercased()])
        }

        return docs
    }

    func generateDBName() -> String {
        return "a-\(NSUUID().uuidString.lowercased())"
    }

    func createDatabase(databaseName: String, client: CouchDBClient) -> Void {
        let create = CreateDatabaseOperation(name: databaseName) { (response, httpInfo, error) in
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        let nsOperation = Operation(couchOperation: create)
        client.add(operation: nsOperation)
        nsOperation.waitUntilFinished()
    }

    func deleteDatabase(databaseName: String, client: CouchDBClient) -> Void {
        let delete = DeleteDatabaseOperation(name: databaseName) { (response, httpInfo, error) in
            XCTAssertNotNil(httpInfo)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        client.add(operation: delete).waitUntilFinished()
    }
    
    func simulateCreatedResponseFor(operation: CouchOperation, jsonResponse: JSONResponse = ["ok": true, "rev": "1-thisisarevision"]) {
        simulateExecutionOf(operation: operation, httpResponse: HTTPInfo(statusCode: 201, headers: [:]), response: jsonResponse)
    }
    
    func simulateOkResponseFor(operation: CouchOperation, jsonResponse: JSONResponse = ["ok" : true]) {
        simulateExecutionOf(operation: operation, httpResponse: HTTPInfo(statusCode: 200, headers: [:]), response: jsonResponse)
    }
    
    func simulateExecutionOf(operation: CouchOperation, httpResponse: HTTPInfo, response: JSONResponse) {
        do {
            let data = try JSONSerialization.data(withJSONObject: response.json)
            let httpInfo = HTTPInfo(statusCode: 200, headers: [:])
            self.simulateExecutionOf(operation: operation, httpResponse: httpInfo, response: data)
        } catch {
            NSLog("Failed to seralise json, aborting simulation")
        }

    }
    
    func simulateExecutionOf(operation: CouchOperation, httpResponse: HTTPInfo, response: Data) {
        DispatchQueue.main.async {
            
            do {
                if !operation.validate() {
                    operation.callCompletionHandler(error: Operation.Error.validationFailed)
                }
                
                try operation.serialise()
                
                operation.processResponse(data: response, httpInfo: httpResponse, error: nil)
            } catch {
                operation.callCompletionHandler(error: error)
            }
            
            
        }
    }
    
}

struct JSONResponse: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    
    let array: [Any]?
    let dictionary: [String:Any]?
    
    init(arrayLiteral:Any...){
        
        array = Array<Any>(arrayLiteral: arrayLiteral)
        dictionary = nil
    }
    
    init(dictionaryLiteral elements: (String, Any)...){
        array = nil
        var mutableDict: [String:Any] = [:]
        for (key, value) in elements {
            mutableDict[key] = value
        }
        dictionary = mutableDict
    }
    
    init(dictionary: [String: Any]){
        self.dictionary = dictionary
        self.array = nil
    }
    
    var json: Any {
        get {
            if let array = array {
                return array
            }
            
            if let dictionary = dictionary {
                return dictionary
            }
            
            return Dictionary<String,Any>() // return empty dict just in case all else fails.
        }
    }

    
}

extension Array where Element: NSURLQueryItem {

    /**
     Checks if this array is equivalent to another array. For an array to be equivalent to another
     they need to contain the same elements, however they do __not__ need to be in the same order.

     - parameter to: the `[NSURLQueryItem]` to compare to.
     */
    func isEquivalent(to: [NSURLQueryItem]) -> Bool {
        var to = to
        if (self.count != to.count) {
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

    fileprivate let settings: [String: Any];
    private static var instance: TestSettings?

    private init() {
        // load the settings from the evnvironment this is a workaround while we cannot
        // specify files to be part of the bundle for loading test cases.
        let keys = ["TEST_COUCH_URL",  "TEST_COUCH_USERNAME", "TEST_COUCH_PASSWORD"]
        let filtered = ProcessInfo.processInfo.environment.filter {
            return keys.contains($0.key)
        }
        
        var tempSettings: [String:Any] = [:]
        for (key, value) in filtered {
            tempSettings[key] = value
        }
        self.settings = tempSettings
        
        // uncomment this when it is possible to bundle files with SPM.
//        let bundle = Bundle(for: TestSettings.self)
//
//        let testSettingsPath = bundle.path(forResource: "TestSettings", ofType: "plist")
//
//        if let testSettingsPath = testSettingsPath,
//            let settingsDict = NSDictionary(contentsOfFile: testSettingsPath) as? [String: Any] {
//                settings = settingsDict
//        } else {
//                settings = [:]
//        }
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
