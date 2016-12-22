//
//  CouchClientTest.swift
//  SwiftCloudant
//
//  Created by Sam Smith on 19/12/2016.
//
//

import Foundation
import XCTest
@testable import SwiftCloudant

class CouchClientTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanAllocateAndDeallocateCouchDBClient() {
        // Previously client would cause a crash where we deallocated an unsued client, i.e. no requests have been made.
        let url = URL(string: "https://example:xxxxxxx@example.cloudant.com")!
        let _ = CouchDBClient(url: url, username: url.user, password: url.password)
    }
}
