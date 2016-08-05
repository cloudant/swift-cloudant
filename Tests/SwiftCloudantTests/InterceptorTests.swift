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
@testable import SwiftCloudant

let testCookieHeaderValue = "AuthSession=cm9vdDo1MEJCRkYwMjq0LO0ylOIwShrgt8y-UkhI-c6BGw";

class InterceptorTests: XCTestCase {
    
    var session: URLSession?
    
    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CookieSession401.self, CookieSession200.self]
        session = URLSession(configuration: configuration)
    }

    func testCookieInterceptorSucessfullGetsCookie() {
        let cookieInterceptor = SessionCookieInterceptor(username: "username", password: "password", session: session!)

        // create a context with a request which we can use
        let url = URL(string: "http://username.cloudant.com")!
        let request = URLRequest(url: url)

        var ctx = HTTPInterceptorContext(request: request, response: nil, shouldRetry: false)

        ctx = cookieInterceptor.interceptRequest(in: ctx)

        XCTAssertEqual(cookieInterceptor.cookie, testCookieHeaderValue)
        XCTAssertEqual(cookieInterceptor.shouldMakeSessionRequest, true);
        XCTAssertEqual(ctx.request.value(forHTTPHeaderField: "Cookie"), testCookieHeaderValue)

    }

    func testCookieInterceptorHandles401 () {
        let cookieInterceptor = SessionCookieInterceptor(username: "username",
                                                         password: "password",
                                                         session: session!)

        // create a context with a request which we can use
        let url = URL(string: "http://username1.cloudant.com")!
        let request = URLRequest(url: url)

        var ctx = HTTPInterceptorContext(request: request, response: nil, shouldRetry: false)

        ctx = cookieInterceptor.interceptRequest(in: ctx)

        XCTAssertNil(cookieInterceptor.cookie)
        XCTAssertEqual(cookieInterceptor.shouldMakeSessionRequest, false);
        XCTAssertNil(ctx.request.value(forHTTPHeaderField: "Cookie"))
    }
}

class CookieSessionHTTPURLProtocol: URLProtocol {
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    func sendResponse(statusCode: Int, headers: [String:String] = [:], json: JSONResponse){
        do {
            let data = try JSONSerialization.data(withJSONObject: json.json)
            self.sendResponse(statusCode: statusCode, headers: headers, data: data)
        } catch {
            
            NSLog("Failed to create NSData for JSONResponse, error:\(error)")
            self.sendResponse(statusCode: statusCode, headers: headers, data: Data())
            
        }
    }
    
    func sendResponse(statusCode: Int, headers: [String:String] = [:], data: Data){
        DispatchQueue(label: "com.cloudant.cookie.session.protocol", attributes: []).async {
            let response = HTTPURLResponse(url: self.request.url!, statusCode: statusCode, httpVersion: "http/1.1", headerFields: headers)
            self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        return
    }

}

class CookieSession401 : CookieSessionHTTPURLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "username1.cloudant.com"
    }

    override func startLoading() {
        sendResponse(statusCode: 401, json: [:])
    }

}

class CookieSession200 : CookieSessionHTTPURLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "username.cloudant.com"
    }
    
    override func startLoading() {
        sendResponse(statusCode: 200, headers: ["Set-Cookie": "\(testCookieHeaderValue); Version=1; Path=/; HttpOnly"], json: ["ok": true, "name": "username", "roles": ["_admin"]])
    }
 
}







