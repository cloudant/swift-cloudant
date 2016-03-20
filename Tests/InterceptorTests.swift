//
//  InterceptorTests.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 18/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation
import XCTest
import OHHTTPStubs
@testable import SwiftCloudant

let testCookieHeaderValue = "AuthSession=cm9vdDo1MEJCRkYwMjq0LO0ylOIwShrgt8y-UkhI-c6BGw";

class InterceptorTests : XCTestCase {
    
    
    
    override func setUp() {
        
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL!.host! == "username1.cloudant.com"
            }) { (request) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(JSONObject: [:], statusCode: 401, headers: [:])
        }
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL!.host! == "username.cloudant.com"
            }) { (request) -> OHHTTPStubsResponse in
                if request.HTTPMethod == "POST" {
                    //do the post thing
                    return OHHTTPStubsResponse(JSONObject: ["ok":true, "name":"username", "roles":["_admin"]],
                        statusCode: 200,
                        headers: ["Set-Cookie": "\(testCookieHeaderValue); Version=1; Path=/; HttpOnly"])
                } else {
                    return OHHTTPStubsResponse(JSONObject: [:], statusCode: 200, headers: [:])
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
        let request = NSMutableURLRequest(URL: url)
        
        var ctx = HTTPInterceptorContext(request: request, response: nil, shouldRetry: false)
        
        ctx = cookieInterceptor.interceptRequest(ctx)
        
        XCTAssertEqual(cookieInterceptor.cookie, testCookieHeaderValue)
        XCTAssertEqual(cookieInterceptor.shouldMakeSessionRequest, true);
        XCTAssertEqual(ctx.request.valueForHTTPHeaderField("Cookie"), testCookieHeaderValue)
        
    }
    
    func testCookieInterceptorHandles401 () {
        let cookieInterceptor = SessionCookieInterceptor(username: "username", password: "password")
        
        // create a context with a request which we can use
        let url = NSURL(string: "http://username1.cloudant.com")!
        let request = NSMutableURLRequest(URL: url)
        
        var ctx = HTTPInterceptorContext(request: request, response: nil, shouldRetry: false)
        
        ctx = cookieInterceptor.interceptRequest(ctx)
        
        XCTAssertNil(cookieInterceptor.cookie)
        XCTAssertEqual(cookieInterceptor.shouldMakeSessionRequest, false);
        XCTAssertNil(ctx.request.valueForHTTPHeaderField("Cookie"))
    }
}
