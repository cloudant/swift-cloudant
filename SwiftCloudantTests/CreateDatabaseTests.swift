//
//  CreateDatabaseTests.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
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
        client.addOperation(delete)
        delete.waitUntilFinished()
        
        super.tearDown()
        
        
    }
    
    
    func testCreateUsingPut() {
        
        let createExpectation = self.expectationWithDescription("create database")
        
        let client = CouchDBClient(url:NSURL(string: url)!,username:username,password:password)
        
        let create = CreateDatabaseOperation()
        create.databaseName = self.dbName
        create.createDatabaseCompletionBlock = {( statusCode, error) in
            createExpectation.fulfill()
            XCTAssertNotNil(statusCode)
            if let statusCode = statusCode {
                XCTAssertTrue(statusCode / 100 == 2)
            }
            XCTAssertNil(error)
        }
        
        client.addOperation(create)
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }

    
}