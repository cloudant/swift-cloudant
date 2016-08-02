//
//  ViewPagingTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 02/08/2016.
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

class ViewPagingTests : XCTestCase {
    
    var client: CouchDBClient? = nil
    var dbName: String = ""
    
    override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName, client: client!)
        
        
        let mapFunc = "function (doc) { emit(doc._id, null) }"
        let ddoc = ["views": ["paging": ["map": mapFunc]]]
        
        let createDoc = PutDocumentOperation(id:"_design/paging", body: ddoc, databaseName: dbName) { response, httpInfo, error in
            XCTAssertNil(error)
            XCTAssertNotNil(httpInfo)
            XCTAssertNotNil(response)
            if let httpInfo = httpInfo {
                XCTAssert(httpInfo.statusCode / 100 == 2)
            }
        }
        client?.add(operation: createDoc).waitUntilFinished()
        
        var count:Int = 0
        for doc in createTestDocuments(count: 10) {
            let putDoc = PutDocumentOperation(id: "paging-\(count)", body: doc, databaseName: dbName) { response, httpInfo, error in
                XCTAssertNotNil(response)
                XCTAssertNotNil(httpInfo)
                XCTAssertNil(error)
                
            }
            client?.add(operation: putDoc).waitUntilFinished()
            count += 1
        }
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName, client: client!)
        
        super.tearDown()
        
        print("Deleted database: \(dbName)")
    }
    
    func testPageForward(){
        
        let expectation = self.expectation(description: "Paging views")
        
        var firstPage: [String:Any] = [:]
        var isFirst: Bool = true
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNil(error)
            if let page = page {
                if isFirst {
                    firstPage = page
                } else {
                    XCTAssertNotEqual(firstPage as NSDictionary, page as NSDictionary)
                }
                
                let ids = self.extractIDs(from: page)
                XCTAssertEqual(5, ids.count)
                
                var startNumber: Int
                if isFirst {
                    startNumber = 0
                } else {
                    startNumber = 5
                }
                
                for id in ids {
                    let last = id.components(separatedBy: "-").last!
                    XCTAssertEqual(startNumber, Int(last))
                    startNumber += 1
                    
                }
            }
            
            if !isFirst {
                expectation.fulfill()
            }
            
            if isFirst {
                isFirst = false
                return .next
            } else {
                return nil
            }
            
        }
        
        // Start paging.
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        
    }
    
    func testPageBackward(){
        
        let expectation = self.expectation(description: "Paging views")
        
        var firstPage: [String:Any] = [:]
        var isFirst: Bool = true
        var isSecond: Bool = false
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNil(error)
            
            if let page = page {
                if isFirst {
                    firstPage = page
                    isFirst = false
                    isSecond = true
                    return .next
                } else if isSecond {
                    XCTAssertNotEqual(firstPage as NSDictionary, page as NSDictionary)
                    isSecond = false
                    return .previous
                } else {
                    XCTAssertEqual((firstPage["rows"] as! NSArray), (page["rows"] as! NSArray))
                }
                
                let ids = self.extractIDs(from: page)
                XCTAssertEqual(5, ids.count)
                
                var startNumber = 0
                
                for id in ids {
                    let last = id.components(separatedBy: "-").last!
                    XCTAssertEqual(startNumber, Int(last))
                    startNumber += 1
                    
                }
            }
            
            if !isSecond && !isFirst {
                expectation.fulfill()
            }
            
            return nil
            
        }
        
        // Start paging.
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        
    }
    
    func testPageForwardDescending(){
        
        let expectation = self.expectation(description: "Paging views")
        
        var firstPage: [String:Any] = [:]
        var isFirst: Bool = true
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5, descending: true){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNil(error)
            if let page = page {
                if isFirst {
                    firstPage = page
                } else {
                    XCTAssertNotEqual(firstPage as NSDictionary, page as NSDictionary)
                }
                
                let ids = self.extractIDs(from: page)
                XCTAssertEqual(5, ids.count)
                
                var startNumber: Int
                if isFirst {
                    startNumber = 9
                } else {
                    startNumber = 4
                }
                
                for id in ids {
                    let last = id.components(separatedBy: "-").last!
                    XCTAssertEqual(startNumber, Int(last))
                    startNumber -= 1
                    
                }
            }
            
            if !isFirst {
                expectation.fulfill()
            }
            
            if isFirst {
                isFirst = false
                return .next
            } else {
                return nil
            }
            
        }
        
        // Start paging.
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        
    }
    
    func testPageBackwardDescending(){
        
        let expectation = self.expectation(description: "Paging views")
        
        var firstPage: [String:Any] = [:]
        var isFirst: Bool = true
        var isSecond: Bool = false
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5, descending: true){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNil(error)
            
            if let page = page {
                if isFirst {
                    firstPage = page
                    isFirst = false
                    isSecond = true
                    return .next
                } else if isSecond {
                    XCTAssertNotEqual(firstPage as NSDictionary, page as NSDictionary)
                    isSecond = false
                    return .previous
                } else {
                    XCTAssertEqual((firstPage["rows"] as! NSArray), (page["rows"] as! NSArray))
                }
                
                let ids = self.extractIDs(from: page)
                XCTAssertEqual(5, ids.count)
                
                var startNumber = 9
                
                for id in ids {
                    let last = id.components(separatedBy: "-").last!
                    XCTAssertEqual(startNumber, Int(last))
                    startNumber -= 1
                }
            }
            
            if !isSecond && !isFirst {
                expectation.fulfill()
            }
            
            return nil
            
        }
        
        // Start paging.
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        
    }
    
    func extractIDs(from response: [String :Any]) -> [String]{
        
        let rows = response["rows"] as! [[String :Any]]
        return rows.reduce([]) { (partialResult, row) -> [String] in
            var partialResult = partialResult
            partialResult.append(row["id"] as! String)
            return partialResult
        }

    }
    
    func testPageForwardFinalPageLessThanPageSize(){
        
        let expectation = self.expectation(description: "Paging views")
        
        var previousRows: [[String:Any]] = []
        var isFirst: Bool = true
        var isSecond: Bool = false
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 4){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNil(error)
            
            
            if let page = page, let rows = page["rows"] as? [[String:Any]] {
                
                for row in rows {
                    XCTAssertFalse(previousRows.contains {
                        ($0 as NSDictionary).isEqual(to: row as NSDictionary)
                    })
                }
                
                previousRows.append(contentsOf: rows)
                
                let ids = self.extractIDs(from: page)
                if isFirst || isSecond {
                    XCTAssertEqual(4, ids.count)
                } else {
                    XCTAssertEqual(2, ids.count)
                }
                
                var startNumber: Int
                if isFirst {
                    startNumber = 0
                } else if isSecond {
                    startNumber = 4
                } else {
                    startNumber = 8
                }
                
                for id in ids {
                    let last = id.components(separatedBy: "-").last!
                    XCTAssertEqual(startNumber, Int(last))
                    startNumber += 1
                }
                
                if isFirst {
                    isSecond = true
                    isFirst = false
                    return .next
                } else if isSecond {
                    isSecond = false
                    return .next
                } else {
                    expectation.fulfill()
                    return nil
                }
            }
            
            return .next
        }
        
        // Start paging.
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 30.0)
        
    }
    
    func testPageBackwardsUsingToken(){
        
        let expectation = self.expectation(description: "Paging views")
  
        
        var previousRows: [[String:Any]] = []
        
        var pageToken: ViewPager.Token?
        var firstPage: Bool = true
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            XCTAssertNil(error)
            if !firstPage {
                pageToken = token
            }
            
            if let page = page, let rows = page["rows"] as? [[String:Any]] {
                if firstPage {
                    previousRows = rows
                }
                XCTAssertEqual(5, rows.count)
            }
            
            if firstPage {
                firstPage = false
                return .next
            } else {
                expectation.fulfill()
                return nil
            }
        }
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        guard let token = pageToken else {
            return
        }
        
        let tokenPageExpectation = self.expectation(description: "Paging views with token")
        ViewPager.previous(token: token){ page, token, error in
        
            XCTAssertNil(error)
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            if let page = page {
                XCTAssertEqual(previousRows as NSArray, page["rows"] as? NSArray )
            }
            
            tokenPageExpectation.fulfill()
            return nil
        }
        
        self.waitForExpectations(timeout: 10.0)
        
    }
    
    
    /*
 
     First Page -> Second page -
            ^                  |
            |------------------|
     
     
     Token -----> Second Page.
 
    */
    
    func testPageForwardsUsingToken(){
        
        let expectation = self.expectation(description: "Paging views")
        
        
        var previousRows: [[String:Any]] = []
        
        var pageToken: ViewPager.Token?
        var firstPage: Bool = true
        var secondPage: Bool = false
        var thirdPage: Bool = false
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            XCTAssertNil(error)
            if thirdPage { // this should be the same as getting the first page token.
                pageToken = token
            }
            
            if let page = page, let rows = page["rows"] as? [[String:Any]] {
                if secondPage {
                    previousRows = rows
                }
                XCTAssertEqual(5, rows.count)
            }
            
            if firstPage {
                firstPage = false
                secondPage = true
                return .next
            } else if secondPage {
                secondPage = false
                thirdPage = true
                return .previous
            } else {
                expectation.fulfill()
                return nil
            }
        }
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        guard let token = pageToken else {
            return
        }
        
        let tokenPageExpectation = self.expectation(description: "Paging views with token")
        ViewPager.next(token: token){ page, token, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            if let page = page {
                XCTAssertEqual(previousRows as NSArray, page["rows"] as? NSArray )
            }
            
            tokenPageExpectation.fulfill()
            return nil
        }
        
        self.waitForExpectations(timeout: 10.0)
        
    }
    
    func testPageBackwardsUsingTokenString() throws {
        
        let expectation = self.expectation(description: "Paging views")
        
        
        var previousRows: [[String:Any]] = []
        
        var pageToken: ViewPager.Token?
        var firstPage: Bool = true
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            XCTAssertNil(error)
            if !firstPage {
                pageToken = token
            }
            
            if let page = page, let rows = page["rows"] as? [[String:Any]] {
                if firstPage {
                    previousRows = rows
                }
                XCTAssertEqual(5, rows.count)
            }
            
            if firstPage {
                firstPage = false
                return .next
            } else {
                expectation.fulfill()
                return nil
            }
        }
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        guard let token = pageToken else {
            return
        }
        
        let stringToken = try token.serialised()
        
        
        let tokenPageExpectation = self.expectation(description: "Paging views with token")
        try ViewPager.previous(token: stringToken, client: self.client!){ page, token, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            if let page = page {
                XCTAssertEqual(previousRows as NSArray, page["rows"] as? NSArray )
            }
            
            tokenPageExpectation.fulfill()
            return nil
        }
        
        self.waitForExpectations(timeout: 10.0)
        
    }
    
    
    /*
     
     First Page -> Second page -
     ^                  |
     |------------------|
     
     
     Token -----> Second Page.
     
     */
    
    func testPageForwardsUsingTokenString() throws {
        
        let expectation = self.expectation(description: "Paging views")
        
        
        var previousRows: [[String:Any]] = []
        
        var pageToken: ViewPager.Token?
        var firstPage: Bool = true
        var secondPage: Bool = false
        var thirdPage: Bool = false
        
        let viewPage = ViewPager(name: "paging", designDocumentID: "paging", databaseName: dbName, client: client!, pageSize: 5){ (page: [String : Any]?, token: ViewPager.Token?, error: Error?) -> ViewPager.Page? in
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            XCTAssertNil(error)
            if thirdPage { // this should be the same as getting the first page token.
                pageToken = token
            }
            
            if let page = page, let rows = page["rows"] as? [[String:Any]] {
                if secondPage {
                    previousRows = rows
                }
                XCTAssertEqual(5, rows.count)
            }
            
            if firstPage {
                firstPage = false
                secondPage = true
                return .next
            } else if secondPage {
                secondPage = false
                thirdPage = true
                return .previous
            } else {
                expectation.fulfill()
                return nil
            }
        }
        viewPage.makeRequest()
        
        self.waitForExpectations(timeout: 20.0)
        
        guard let token = pageToken else {
            return
        }
        
        let tokenPageExpectation = self.expectation(description: "Paging views with token")
        let stringToken = try token.serialised()
        try ViewPager.next(token: stringToken, client: client!){ page, token, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(page)
            XCTAssertNotNil(token)
            if let page = page {
                XCTAssertEqual(previousRows as NSArray, page["rows"] as? NSArray )
            }
            
            tokenPageExpectation.fulfill()
            return nil
        }
        
        self.waitForExpectations(timeout: 10.0)
        
    }
    

    
}

