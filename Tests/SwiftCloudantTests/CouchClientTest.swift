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

    private class VCAPGenerator {

        private var VCAPServices = ["cloudantNoSQLDB": []]

        public func addService(name: String?, url: String?) {
            var VCAPService = [String:Any]()
            if name != nil {
                VCAPService["name"] = name!
            }
            if url != nil {
                if url == "" {
                    VCAPService["credentials"] = [] // empty credentials array
                } else {
                    VCAPService["credentials"] = ["url": url!]
                }
            }

            VCAPServices["cloudantNoSQLDB"]!.append(VCAPService)
        }

        public func toJSONString() throws -> String {
            let json = try JSONSerialization.data(withJSONObject: VCAPServices)
            return String(data: json, encoding: .utf8)!
        }
    }

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

    func testEmptyVCAPServiceJSONFailure() {
        XCTAssertThrowsError(try CouchDBClient(vcapServices: "{}", instanceName: "myInstance")) { (error) -> Void in
            XCTAssertEqual(error as? CouchDBClient.Error, CouchDBClient.Error.missingCloudantService)
        }
    }

    func testMissingVCAPServiceJSONFailure() {
        XCTAssertThrowsError(try CouchDBClient(vcapServices: "", instanceName: "myInstance")) { (error) -> Void in
            XCTAssertEqual(error as? CouchDBClient.Error, CouchDBClient.Error.invalidVCAP)
        }
    }

    func testGetInstanceWithNameFromSingleVCAPServiceJSON() throws {
        let vcap = VCAPGenerator()
        // create VCAP
        vcap.addService(name: "example1", url: "https://example1:xxxxxxx@example1.cloudant.com")

        let client = try CouchDBClient(vcapServices: vcap.toJSONString(), instanceName: "example1")
        XCTAssertEqual("example1", client.username)
        XCTAssertEqual("xxxxxxx", client.password)
        XCTAssertEqual("https://example1:xxxxxxx@example1.cloudant.com", client.rootURL.absoluteString)
    }

    func testGetInstanceWithoutNameFromSingleVCAPServiceJSON() throws {
        let vcap = VCAPGenerator()
        // create VCAP
        vcap.addService(name: "example1", url: "https://example1:xxxxxxx@example1.cloudant.com")

        let client = try CouchDBClient(vcapServices: vcap.toJSONString())
        XCTAssertEqual("example1", client.username)
        XCTAssertEqual("xxxxxxx", client.password)
        XCTAssertEqual("https://example1:xxxxxxx@example1.cloudant.com", client.rootURL.absoluteString)
    }

    func testGetInstanceWithNameFromMultiVCAPServiceJSON() throws {
        let vcap = VCAPGenerator()
        // create VCAP
        vcap.addService(name: "example1", url: "https://example1:xxxxxxx@example1.cloudant.com")
        vcap.addService(name: "example2", url: "https://example2:xxxxxxx@example2.cloudant.com")

        let client = try CouchDBClient(vcapServices: vcap.toJSONString(), instanceName: "example1")
        XCTAssertEqual("example1", client.username)
        XCTAssertEqual("xxxxxxx", client.password)
        XCTAssertEqual("https://example1:xxxxxxx@example1.cloudant.com", client.rootURL.absoluteString)
    }

    func testGetInstanceWithoutNameFromMultiVCAPServiceJSON() throws {
        let vcap = VCAPGenerator()
        // create VCAP
        vcap.addService(name: "example1", url: "https://example1:xxxxxxx@example1.cloudant.com")
        vcap.addService(name: "example2", url: "https://example2:xxxxxxx@example2.cloudant.com")

        XCTAssertThrowsError(try CouchDBClient(vcapServices: vcap.toJSONString())) { (error) -> Void in
            XCTAssertEqual(error as? CouchDBClient.Error, CouchDBClient.Error.instanceNameRquired)
        }
    }

    func testMissingNamedVCAPServiceJSON() throws {
        let vcap = VCAPGenerator()
        // create VCAP
        vcap.addService(name: "example1", url: "https://example1:xxxxxxx@example1.cloudant.com")
        vcap.addService(name: "example2", url: "https://example2:xxxxxxx@example2.cloudant.com")

        XCTAssertThrowsError(try CouchDBClient(vcapServices: vcap.toJSONString(), instanceName: "example3")) { (error) -> Void in
            XCTAssertEqual(error as? CouchDBClient.Error, CouchDBClient.Error.missingCloudantService)
        }
    }

    func testMissingCredentialsFromVCAPServiceJSON() throws {
        let vcap = VCAPGenerator()
        // create VCAP
        vcap.addService(name: "example1", url: nil) // missing credentials

        XCTAssertThrowsError(try CouchDBClient(vcapServices: vcap.toJSONString(), instanceName: "example1")) { (error) -> Void in
            XCTAssertEqual(error as? CouchDBClient.Error, CouchDBClient.Error.invalidVCAP)
        }
    }

    func testMissingURLFromVCAPServiceJSON() throws {
        let vcap = VCAPGenerator()
        // create VCAP
        vcap.addService(name: "example1", url: "") // missing url

        XCTAssertThrowsError(try CouchDBClient(vcapServices: vcap.toJSONString(), instanceName: "example1")) { (error) -> Void in
            XCTAssertEqual(error as? CouchDBClient.Error, CouchDBClient.Error.invalidVCAP)
        }
    }
}
