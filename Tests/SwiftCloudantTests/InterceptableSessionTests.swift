//
//  InterceptableSessionTests.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 19/08/2016.
//
//  Copyright (C) 2016 IBM Corp.
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

let testCookieHeaderValue = "AuthSession=cm9vdDo1MEJCRkYwMjq0LO0ylOIwShrgt8y-UkhI-c6BGw; Version=1; Domain=.cloudant.com; Path=/; HttpOnly";

class InterceptableSessionTests : XCTestCase {
    
    static var allTests = {
        return [
            ("testInterceptableSessionBacksOff", testInterceptableSessionBacksOff),
            ("testInterceptableSessionBackOffMax",testInterceptableSessionBackOffMax),
            ("test429ConfiguredViaClient",test429ConfiguredViaClient),
            ("testInterceptableSessionNoBackOff",testInterceptableSessionNoBackOff),
            ("testBackSetHigherThanAllowedRetries",testBackSetHigherThanAllowedRetries),]
    }()
    
    
    lazy var sessionConfig = {() -> URLSessionConfiguration in
        let config = URLSessionConfiguration.default
        config.protocolClasses = [BackOffHTTPURLProtocol.self,
                                  CookieSession401.self,
                                  CookieSession200.self,
                                  CookieSession200Then403.self,
                                  CookieSession200Then401.self,
                                  CookieSession403.self
        ]
        return config
    
    }()
    
    override func setUp() {
        super.setUp()
        // Since we share cookie storage, we need to clear up any state previously left behind
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    }
    
    override func tearDown() {
        super.tearDown()
        // Since we shared cookie storage, we need to try not to leave any state behind
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    }
    
    func testInterceptableSessionBacksOff() throws {
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff:true))
        session.session = URLSession(configuration: sessionConfig, delegate: session, delegateQueue: nil)
        
        guard let url = URL(string:"http://example.com") else {
            XCTFail("Failed to create url with http://example.com")
            return
        }
        
        let request = URLRequest(url: url)
        
        
        let delegate = RequestDelegate(expectation: self.expectation(description:"429 back off request"))
        let task = session.dataTask(request: request, delegate: delegate)
        task.resume() // start the task processing.
        
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(2, remainingBackOffRetries(for: task))
        XCTAssertEqual(200, delegate.response?.statusCode)
        XCTAssertNil(delegate.error)
        XCTAssertNotNil(delegate.data)
        XCTAssertEqual(9, remainingTotalRetries(for: task))
    }
    
    
    func testInterceptableSessionBackOffMax() throws {
        let config = sessionConfig
        config.protocolClasses = [AlwaysBackOffHTTPURLProtocol.self]
        
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff:true))
        session.session = URLSession(configuration: config, delegate: session, delegateQueue: nil)
        
        guard let url = URL(string:"http://example.com") else {
            XCTFail("Failed to create url with http://example.com")
            return
        }
        
        let request = URLRequest(url: url)
        
        
        let delegate = RequestDelegate(expectation: self.expectation(description:"429 back off request"))
        let task = session.dataTask(request: request, delegate: delegate)
        task.resume() // start the task processing.
        
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(0, remainingBackOffRetries(for: task))
        XCTAssertEqual(429, delegate.response?.statusCode)
        XCTAssertNil(delegate.error)
        XCTAssertNotNil(delegate.data)
        XCTAssertEqual(7, remainingTotalRetries(for: task))
    }
    
    func testBackSetHigherThanAllowedRetries() throws {
        let config = sessionConfig
        config.protocolClasses = [AlwaysBackOffHTTPURLProtocol.self]
        
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(maxRetries: 3, shouldBackOff:true, backOffRetries: 4))
        session.session = URLSession(configuration: config, delegate: session, delegateQueue: nil)
        
        guard let url = URL(string:"http://example.com") else {
            XCTFail("Failed to create url with http://example.com")
            return
        }
        
        let request = URLRequest(url: url)
        
        
        let delegate = RequestDelegate(expectation: self.expectation(description:"429 back off request"))
        let task = session.dataTask(request: request, delegate: delegate)
        task.resume() // start the task processing.
        
        self.waitForExpectations(timeout: 20.0)
        
        XCTAssertEqual(1, remainingBackOffRetries(for: task))
        XCTAssertEqual(429, delegate.response?.statusCode)
        XCTAssertNil(delegate.error)
        XCTAssertNotNil(delegate.data)
        XCTAssertEqual(0, remainingTotalRetries(for: task))
    }
    
    func test429ConfiguredViaClient() throws {
        
        let expectation = self.expectation(description: "429 from example.com")
        
        let client = CouchDBClient(url: URL(string: "http://example.com")!,
                                   username: username,
                                   password: password,
                                   configuration: ClientConfiguration(shouldBackOff:true))
        let config = sessionConfig
        config.protocolClasses = [AlwaysBackOffHTTPURLProtocol.self]
        
        //get the seesion from the client.
        
        guard let session = interceptableSession(for: client)
        else {
            XCTFail("Failed to get session instance from client")
            return
        }
        session.session = URLSession(configuration: config, delegate: session, delegateQueue: nil)
        
        let createDB = CreateDatabaseOperation(name: "test") {(response, info, error) in
            XCTAssertNotNil(response)
            XCTAssertNotNil(info)
            XCTAssertNotNil(error)
            if let info = info {
                XCTAssertEqual(429, info.statusCode)
            }
            expectation.fulfill()
        }
        
        client.add(operation: createDB)
        self.waitForExpectations(timeout: 10.0)
    
    
    }
    
    func testInterceptableSessionNoBackOff() throws {
        let config = sessionConfig
        config.protocolClasses = [AlwaysBackOffHTTPURLProtocol.self]
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff: false))
        session.session = URLSession(configuration: config, delegate: session, delegateQueue: nil)
        
        guard let url = URL(string:"http://example.com") else {
            XCTFail("Failed to create url with http://example.com")
            return
        }
        
        let request = URLRequest(url: url)
        
        
        let delegate = RequestDelegate(expectation: self.expectation(description:"429 back off request"))
        let task = session.dataTask(request: request, delegate: delegate)
        task.resume() // start the task processing.
        
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(3, remainingBackOffRetries(for: task))
        XCTAssertEqual(429, delegate.response?.statusCode)
        XCTAssertNil(delegate.error)
        XCTAssertNotNil(delegate.data)
        XCTAssertEqual(10, remainingTotalRetries(for: task))
    }
    
    func testSessionSucessfullyGetsCookie() throws {
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff:true, username:"username", password:"password"))
        session.session = URLSession(configuration: sessionConfig, delegate: session, delegateQueue: nil)
        
        // create a context with a request which we can use
        let url = URL(string: "http://username.cloudant.com")!
        let request = URLRequest(url: url)
        
        let expectation = self.expectation(description: "First Request - Get Cookie")
        let task = session.dataTask(request: request, delegate: RequestDelegate(expectation: expectation))
        task.resume()
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(self.shouldMakeCookieRequestValue(for: session), true)
        
        let sharedCS = HTTPCookieStorage.shared
        let cookies = sharedCS.cookies(for: request.url!)
        let cookie = cookies?.first
        XCTAssertNotNil(cookie)
    }
    
    func testSessionHandlesEndpointConstant401() throws {
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff:true, username:"username", password:"password"))
        session.session = URLSession(configuration: sessionConfig, delegate: session, delegateQueue: nil)
        
        // create a context with a request which we can use
        let url = URL(string: "http://username1.cloudant.com")!
        let request = URLRequest(url: url)
        
        let expectation = self.expectation(description: "10 401 requests/responses")
        let delegate = RequestDelegate(expectation: expectation)
        let task = session.dataTask(request: request, delegate: delegate)
        XCTAssertEqual(10, remainingTotalRetries(for: task))
        task.resume()
        self.waitForExpectations(timeout: 10.0)
        XCTAssertEqual(401, delegate.response?.statusCode)
        XCTAssertEqual(0, remainingTotalRetries(for: task))
    }
    
    func testSessionHandlesCookie401 () throws {
        
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff:true, username:"username", password:"password"))
        session.session = URLSession(configuration: sessionConfig, delegate: session, delegateQueue: nil)
        
        // create a context with a request which we can use
        let url = URL(string: "http://username1.cloudant.com")!
        let request = URLRequest(url: url)
        
        let expectation = self.expectation(description: "First Request - Get Cookie")
        let task = session.dataTask(request: request, delegate: RequestDelegate(expectation: expectation))
        task.resume()
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(self.shouldMakeCookieRequestValue(for: session), false)
        let sharedCS = HTTPCookieStorage.shared
        let cookies = sharedCS.cookies(for: request.url!)
        let cookie = cookies?.first
        XCTAssertNil(cookie)
    }
    
    func testSessionHandles403() throws {
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff: false, username:"username", password:"password"))
        session.session = URLSession(configuration: sessionConfig, delegate: session, delegateQueue: nil)
        
        
        let url = URL(string: "http://username2.cloudant.com")!
        let request = URLRequest(url: url)
        
        let expectation = self.expectation(description: "200 - 403 - 200 - 200 request chain.")
        let task = session.dataTask(request: request, delegate: OkResponseAssertingRequestDelegate(expectation: expectation))
        task.resume()
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(self.shouldMakeCookieRequestValue(for: session), true)
        let sharedCS = HTTPCookieStorage.shared
        let cookies = sharedCS.cookies(for: request.url!)
        let cookie = cookies?.first
        XCTAssertNotNil(cookie)
        XCTAssertEqual(2, CookieSession200Then403.sessionRequestCount, "_session endpoint should only be hit twice.")
    }
    
    func testSessionHandles401ForNonCookieRequest() throws {
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff: false, username:"username", password:"password"))
        session.session = URLSession(configuration: sessionConfig, delegate: session, delegateQueue: nil)
        
        
        let url = URL(string: "http://username3.cloudant.com")!
        let request = URLRequest(url: url)
        
        let expectation = self.expectation(description: "200 - 401 - 200 - 200 request chain.")
        let task = session.dataTask(request: request, delegate: OkResponseAssertingRequestDelegate(expectation: expectation))
        task.resume()
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(self.shouldMakeCookieRequestValue(for: session), true)
        let sharedCS = HTTPCookieStorage.shared
        let cookies = sharedCS.cookies(for: request.url!)
        let cookie = cookies?.first
        XCTAssertNotNil(cookie)
        XCTAssertEqual(2, CookieSession200Then401.sessionRequestCount)
    }
    
    func testSessionSessionHandles403NoReason() throws {
        let session = InterceptableSession(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff: false, username:"username", password:"password"))
        session.session = URLSession(configuration: sessionConfig, delegate: session, delegateQueue: nil)
        
        
        let url = URL(string: "http://username4.cloudant.com")!
        let request = URLRequest(url: url)
        
        let expectation = self.expectation(description: "200 - 403")
        let task = session.dataTask(request: request, delegate: ForbiddenResponseAssertingRequestDelegate(expectation: expectation))
        task.resume()
        self.waitForExpectations(timeout: 10.0)
        
        XCTAssertEqual(self.shouldMakeCookieRequestValue(for: session), true)
        let sharedCS = HTTPCookieStorage.shared
        let cookies = sharedCS.cookies(for: request.url!)
        let cookie = cookies?.first
        XCTAssertNotNil(cookie)
    }


    // MARK: Helper Functions
    
    func remainingBackOffRetries(for task: SwiftCloudant.URLSessionTask) -> Int {
        return value(of: "remainingBackOffRetries", for: task)
    }
    
    func remainingTotalRetries(for task: SwiftCloudant.URLSessionTask) -> Int {
        return value(of: "remainingRetries", for: task)
    }
    
    func value(of key:String, for task: SwiftCloudant.URLSessionTask) -> Int {
        let mirror = Mirror(reflecting: task);
        let values = mirror.children.filter { (innerKey, value) in
                return innerKey == key
            }.first
        
        if let value = values?.value as? UInt {
            return Int(value)
        }
        
        return -1
    }
    
    func shouldMakeCookieRequestValue(for session: InterceptableSession) -> Bool {
        let mirror = Mirror(reflecting: session)
        let values = mirror.children.filter { (key, value) in
            return key == "shouldMakeCookieRequest"
        }.first
        
        if let value = values?.value as? Bool {
            return value
        } else {
            XCTFail("Failed to extract \"shouldMakeCookieRequest\" value from session")
            return false
        }
    }
    
    func interceptableSession(for client:CouchDBClient) -> InterceptableSession? {
        let mirror = Mirror(reflecting: client);
        let values = mirror.children.filter { (key, value) in
            return key == "session"
            }.first
        
        if let value = values?.value as? InterceptableSession {
            return value
        }
    
        return nil

    }
    
}

// We need reference type semantics here.
class RequestDelegate: InterceptableSessionDelegate {
    
    private let expectation:XCTestExpectation
    var response: HTTPURLResponse?
    var data: Data = Data()
    var error: Error?
    
    init(expectation: XCTestExpectation){
        self.expectation = expectation
    }
    
    
    func received(response:HTTPURLResponse) {
        self.response = response
    }
    
    func received(data: Data){
        self.data.append(data)
    }
    
    func completed(error: Swift.Error?){
        self.error = error
        self.expectation.fulfill()
    }
}

class OkResponseAssertingRequestDelegate: RequestDelegate {
    
    override func received(response:HTTPURLResponse) {
        super.received(response: response)
        XCTAssertEqual(200, response.statusCode)
    }
}

class ForbiddenResponseAssertingRequestDelegate: RequestDelegate {
    
    
    override func received(response: HTTPURLResponse) {
        super.received(response: response)
        XCTAssertEqual(403, response.statusCode)
    }
    
}

class InterceptableSessionURLProtocol: URLProtocol {
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    func sendCredentialsExpiredResponse() {
        sendResponse(statusCode: 403, json: ["error": "credentials_expired"])
    }
    
    func sendCookieResponse() {
        sendResponse(statusCode: 200, headers: ["Set-Cookie": testCookieHeaderValue ], json: ["ok": true, "name": "username", "roles": ["_admin"]])
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
            let response = HTTPURLResponse(url: self.request.url!, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers)
            self.storeCookies(in: response!)
            self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    /// This relies on the session used using shared cookie storage
    func storeCookies(in response: HTTPURLResponse){
            guard let url = response.url
            else {
                // response doesn't contain a url, log it and return.
               NSLog("URL not present in response, could not extract cookies")
                return
            }
    
            // convert the allHeaderFileds into [String: String]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: response.headerFields, for: response.url!)
    
            let storage = HTTPCookieStorage.shared
                storage.setCookies(cookies, for: url, mainDocumentURL: nil)
    }
    
    override func stopLoading() {
        return
    }
    
}

fileprivate extension HTTPURLResponse {
    
    var headerFields: [String: String] {
        get {
            var headers:[String:String] = [:]
            for (key, value) in self.allHeaderFields {
                let convertedK: String
                let convertedV: String
                
                if let key = key as? String{
                    convertedK = key
                } else {
                    convertedK = "\(key)"
                }
                if let value = value as? String {
                    convertedV = value
                } else {
                    convertedV = "\(value)"
                }
                
                headers[convertedK] = convertedV
            }
            return headers
        }
    }
}

class CookieSession401 : InterceptableSessionURLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "username1.cloudant.com"
    }
    
    override func startLoading() {
        sendResponse(statusCode: 401, json: ["error":"unauthorized"])
    }
    
}

class CookieSession200 : InterceptableSessionURLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "username.cloudant.com"
    }
    
    override func startLoading() {
        
        if self.request.url!.path.contains("_session") {
            sendCookieResponse()
        } else {
            sendResponse(statusCode: 200, json:[:])
        }
    }
    
}



class CookieSession200Then403: InterceptableSessionURLProtocol {
    
    static var sessionRequestCount: Int = 0
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "username2.cloudant.com"
    }
    
    override func startLoading() {
        
        if self.request.url!.path.contains("_session") {
            CookieSession200Then403.sessionRequestCount += 1
            sendCookieResponse()
            
        } else if CookieSession200Then403.sessionRequestCount == 1 { // will send a 403 for first request.
            sendCredentialsExpiredResponse()
        } else {
            sendResponse(statusCode: 200, json:[:])
        }
        
        
        
    }
}

class CookieSession200Then401: InterceptableSessionURLProtocol {
    
    static var sessionRequestCount: Int = 0
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "username3.cloudant.com"
    }
    
    override func startLoading() {
        
        if self.request.url!.path.contains("_session") {
            CookieSession200Then401.sessionRequestCount += 1
            sendCookieResponse()
        } else if CookieSession200Then401.sessionRequestCount == 1 { // will send a 401 for first request.
            sendResponse(statusCode: 401, json: ["error": "unauthroized"])
        } else {
            sendResponse(statusCode: 200, json:[:])
        }

    }
}

class CookieSession403: InterceptableSessionURLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "username4.cloudant.com"
    }
    
    override func startLoading() {
        
        if self.request.url!.path.contains("_session") {
            CookieSession200Then401.sessionRequestCount += 1
            sendCookieResponse()
        } else {
            sendResponse(statusCode: 403, json:[:])
        }
    }
}


class BackOffHTTPURLProtocol: InterceptableSessionURLProtocol {
    
    static var shouldBackOff = true
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "example.com"
    }
    
    override func startLoading() {
        if BackOffHTTPURLProtocol.shouldBackOff {
            sendResponse(statusCode: 429, json: [:])
            BackOffHTTPURLProtocol.shouldBackOff = false
        } else {
            BackOffHTTPURLProtocol.shouldBackOff = true
            sendResponse(statusCode: 200, json: [:])
            
        }
    }
}

class AlwaysBackOffHTTPURLProtocol: InterceptableSessionURLProtocol {
    
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url!.host! == "example.com"
    }
    
    override func startLoading() {
        sendResponse(statusCode: 429, json: [:])
    }
}


