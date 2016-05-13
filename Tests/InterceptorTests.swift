//
//  InterceptorTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 18/03/2016.
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
import OHHTTPStubs
@testable import SwiftCloudant

let testCookieHeaderValue = "AuthSession=cm9vdDo1MEJCRkYwMjq0LO0ylOIwShrgt8y-UkhI-c6BGw";

class InterceptorTests: XCTestCase {

    override func setUp() {

        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.host! == "username1.cloudant.com"
        }) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(jsonObject: [:], statusCode: 401, headers: [:])
        }

        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.host! == "username.cloudant.com"
        }) { (request) -> OHHTTPStubsResponse in
            if request.httpMethod == "POST" {
                // do the post thing
                return OHHTTPStubsResponse(jsonObject: ["ok": true, "name": "username", "roles": ["_admin"]],
                    statusCode: 200,
                    headers: ["Set-Cookie": "\(testCookieHeaderValue); Version=1; Path=/; HttpOnly" as NSString])
            } else {
                return OHHTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: [:])
            }
        }

    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testCookieInterceptorSucessfullGetsCookie() {
        let cookieInterceptor = SessionCookieInterceptor(username: "username", password: "password")

        // create a context with a request which we can use
        let url = NSURL(string: "http://username.cloudant.com")!
        let request = NSMutableURLRequest(url: url)

        var ctx = HTTPInterceptorContext(request: request, response: nil, shouldRetry: false)

        ctx = cookieInterceptor.interceptRequest(ctx: ctx)

        XCTAssertEqual(cookieInterceptor.cookie, testCookieHeaderValue)
        XCTAssertEqual(cookieInterceptor.shouldMakeSessionRequest, true);
        XCTAssertEqual(ctx.request.value(forHTTPHeaderField: "Cookie"), testCookieHeaderValue)

    }

    func testCookieInterceptorHandles401 () {
        let cookieInterceptor = SessionCookieInterceptor(username: "username", password: "password")

        // create a context with a request which we can use
        let url = NSURL(string: "http://username1.cloudant.com")!
        let request = NSMutableURLRequest(url: url)

        var ctx = HTTPInterceptorContext(request: request, response: nil, shouldRetry: false)

        ctx = cookieInterceptor.interceptRequest(ctx: ctx)

        XCTAssertNil(cookieInterceptor.cookie)
        XCTAssertEqual(cookieInterceptor.shouldMakeSessionRequest, false);
        XCTAssertNil(ctx.request.value(forHTTPHeaderField: "Cookie"))
    }
}
