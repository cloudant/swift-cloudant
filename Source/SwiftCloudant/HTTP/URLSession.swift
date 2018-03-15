//
//  URLSession.swft
//  SwiftCloudant
//
//  Created by Rhys Short on 28/02/2016.
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
import Dispatch

/**
    A delegate for receiving data and responses from a URL task.
 */
internal protocol InterceptableSessionDelegate {
    
    /**
     Called when the response is received from the server
     - parameter response: The response received from the server
    */
    func received(response:HTTPURLResponse)
    
    /**
    Called when response data is available from the server, may be called multiple times.
     - parameter data: The data received from the server, this may be only a fraction of the data
     the server is sending as part of the response.
    */
    func received(data: Data)
    
    /**
    Called when the request has completed
     - parameter error: The error that occurred when making the request if any.
    */
    func completed(error: Swift.Error?)
}

/**
 The context for a HTTP interceptor.
 */
public struct HTTPInterceptorContext {
    /**
     The request that will be made, this can be modified to add additional data to the request such
     as session cookie authentication of custom tracking headers.
     */
    var request: URLRequest
    /**
     The response that was received from the server. This will be `nil` if the request errored
     or has not yet been made.
     */
    let response: HTTPURLResponse?
    /**
     A flag that signals to the HTTP layer that it should retry the request.
     */
    var shouldRetry: Bool = false
}

/**
 Configuration for `InterceptableSession`
 */
internal struct InterceptableSessionConfiguration {
    
    /**
     The maximum number of retries the session should make before returning the result of an HTTP request
     */
    internal var maxRetries: UInt
    /**
     The number of times to back off from making requests when a 429 response is encountered
     */
    internal var backOffRetries: UInt
    /**
     Should the session back off, if false the session will not back off and retry automatically.
     */
    internal var shouldBackOff: Bool
    
    /** 
     The initial value to use when backing off.
    */
    internal var initialBackOff: DispatchTimeInterval
    
    internal var username: String?
    
    internal var password: String?
    
    init(maxRetries: UInt = 10, shouldBackOff:Bool,
         backOffRetries: UInt = 3,
         initialBackOff: DispatchTimeInterval = .milliseconds(250),
         username: String? = nil,
         password: String? = nil ){
        
        self.maxRetries = maxRetries
        self.shouldBackOff = shouldBackOff
        self.backOffRetries = backOffRetries
        self.initialBackOff = initialBackOff
        self.username = username
        self.password = password
    }
}

/**
 A class which encapsulates HTTP requests. This class allows requests to be transparently retried.
 */
internal class URLSessionTask {
    fileprivate let request: URLRequest
    fileprivate var inProgressTask: URLSessionDataTask
    fileprivate let session: URLSession
    fileprivate var remainingRetries: UInt = 10
    fileprivate var remainingBackOffRetries: UInt = 3
    fileprivate let delegate: InterceptableSessionDelegate
    
    //This  is for caching before delivering the response to the delegate in the event a 401/403 is
    // encountered.
    fileprivate var response: HTTPURLResponse? = nil
    // Caching of the data before being delivered to the delegate in the event of a 401/403 response.
    fileprivate var data: Data? = nil

    public var state: Foundation.URLSessionTask.State {
        get {
            return inProgressTask.state
        }
    }

    /**
     Creates a URLSessionTask object
     - parameter session: the NSURLSession it should use when making HTTP requests.
     - parameter request: the HTTP request to make
     - parameter inProgressTask: The NSURLSessionDataTask that is performing the request in NSURLSession.
     - parameter delegate: The delegate for this task.
     */
    init(session: URLSession, request: URLRequest, inProgressTask:URLSessionDataTask, delegate: InterceptableSessionDelegate) {
        self.request = request
        self.session = session
        self.delegate = delegate
        self.inProgressTask = inProgressTask
    }

    /**
     Resumes a suspended task
     */
    public func resume() {
        inProgressTask.resume()
    }

    /**
     Cancels the task.
     */
    public func cancel() {
        inProgressTask.cancel()
    }
}

/**
 A class to create `URLSessionTask`
 */
internal class InterceptableSession: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionStreamDelegate {

    // This is lazy because of swift init rules. We can't use self for the delegate until super.init is called, but we
    // can't call super.init until all properties have been initialised. To get around this we lazily create the
    // URLSession instance when it is required.
    internal lazy var session: URLSession = { () -> URLSession in
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent" as AnyHashable: InterceptableSession.userAgent()]
        config.httpCookieAcceptPolicy = .onlyFromMainDocumentDomain
        config.httpCookieStorage = .shared
        
        return URLSession(configuration: config, delegate: self, delegateQueue: nil) }()
    
    private var taskDict: [Foundation.URLSessionTask: URLSessionTask] = [:]
    
    private let delegateQueue = DispatchQueue(label: "com.cloudant.swift.interceptable.session.delegate", attributes: .concurrent)
    
    private let configuration: InterceptableSessionConfiguration
    
    private var isFirstRequest:Bool = true
    
    private let sessionRequestBody: Data? // This will be the body sent to _session.
    
    private var shouldMakeCookieRequest: Bool = true
    
    convenience override init() {
        self.init(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff: false))
        
    }

    /**
     Creates an Interceptable session
     - parameter delegate: a delegate to use for this session.
     - parameter configuration: The configuration for this session.
     */
    init(delegate: URLSessionDelegate?, configuration: InterceptableSessionConfiguration) {
        self.configuration = configuration
        
        if let username = configuration.username, let password = configuration.password {
            let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
            let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
            
            let payload = "name=\(encodedUsername)&password=\(encodedPassword)"
            sessionRequestBody = payload.data(using: .ascii)!
        } else {
            sessionRequestBody = nil;
        }
    }

    /**
     Creates a data task to perform the http request.
     - parameter request: the request the task should make
     - parameter delegate: The delegate for the task being created.
     - returns: A `URLSessionTask` representing the task for the `NSURLRequest`
     */
    internal func dataTask(request: URLRequest, delegate: InterceptableSessionDelegate) -> URLSessionTask {
        
        // Only request another cookie **if** cookie auth is enabled **and** it is the first request
        // for this session, renewals will be handled as tasks complete.
        if let _ = sessionRequestBody, let url = request.url, self.isFirstRequest {
            self.isFirstRequest = false
            requestCookie(url: url)
        }
        
        
        // create the underlying task.
        let nsTask = self.session.dataTask(with: request)
        let task = URLSessionTask(session: session, request: request, inProgressTask: nsTask, delegate: delegate)
        task.remainingRetries = configuration.maxRetries
        task.remainingBackOffRetries = configuration.backOffRetries
        
        self.taskDict[nsTask] = task
        
        return task
    }
    
    
    internal func urlSession(_ session: URLSession, task: Foundation.URLSessionTask, didCompleteWithError error: Error?) {
        guard let mTask = taskDict[task]
        else {
                return
        }
      
        
        // We need to dispatch onto the delegate queue because
        // otherwise we block the delegate queue for the underlying URLSession
        // which will cause 10 minute dead lock whenever we need to renew the cookie.
        // The entire method content is dispatched the seperate delegate queue because this also allows
        // a larger amount of work to be carried out through completion handlers for
        // opertions that will be driven the `completed` delegate method. It is safe to dispatch
        // to our delegate queue because it is a concurrent queue, so blocking for a cookie request
        // will not result in a blocked client.
        self.delegateQueue.async {
            
            // we have a caached response and data, we need to inspect the data to see if we need to renew
            // the cookie.
            if let response = mTask.response, let data = mTask.data {
                let json = try? JSONSerialization.jsonObject(with: data)
                if let json =  json as? [String: Any],
                    let  errorMessage = json["error"] as? String,
                    ( errorMessage == "credentials_expired" || response.statusCode == 401 ),
                    mTask.remainingRetries > 0 { // only 403 may have this message.
                    // we need to get a new cookie and retry the request.
                    mTask.remainingRetries -= 1
                    self.requestCookie(url: mTask.request.url!)
                    
                    //clear the task cache
                    mTask.data = nil;
                    mTask.response = nil;
                    
                    let nsTask = self.session.dataTask(with: mTask.request)
                    self.taskDict[nsTask] = mTask
                    mTask.inProgressTask = nsTask
                    nsTask.resume()
                    return
                }
                
                // unless we return out, we deliver the cached response and data.
                mTask.delegate.received(response: response)
                mTask.delegate.received(data: data)
                
            }
            
            
            mTask.delegate.completed(error: error)
            // remove the task from the dict so it can be released.
            self.taskDict.removeValue(forKey: task)
        }
    }
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = taskDict[dataTask]
        else {
            // perhaps we should also cancel the task if we fail to look it up.
            return
        }
        
        // if the cached response is present in the task, then we need 
        // cache the data being reccieved from the server, otherwise pass it on.
        if let _ = task.response {
            if let _ = task.data {
                task.data?.append(data)
            } else {
                task.data = data
            }
        } else {
            task.delegate.received(data: data)
        }
    }
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // Retrieve the task from the dict.
        guard let task = taskDict[dataTask], let response = response as? HTTPURLResponse
            else {
                completionHandler(.allow)
                return
        }
        
        if task.remainingRetries > 0 {
            
            if response.statusCode == 429 && self.configuration.shouldBackOff && task.remainingBackOffRetries > 0 {
                task.remainingBackOffRetries -= 1
                task.remainingRetries -= 1
                
                let deadline: DispatchWallTime
                
                var backOffTime:DispatchTimeInterval = configuration.initialBackOff
                // calculate the doubling back off.
                for _ in 0...(configuration.backOffRetries - task.remainingBackOffRetries ) {
                    backOffTime = backOffTime * 2
                }
                deadline = DispatchWallTime.now() + backOffTime
                
                // backing off cancel the current request and then make the next one,
                // retry the request.
                self.taskDict.removeValue(forKey: task.inProgressTask)
                task.inProgressTask = self.session.dataTask(with: task.request)
                self.taskDict[task.inProgressTask] = task
                
                completionHandler(.cancel)
                
                self.delegateQueue.asyncAfter(wallDeadline: deadline) {
                    task.resume()
                }
                
            } else if  response.statusCode == 401 || response.statusCode == 403 {
                // response delivery needs to be delayed.
                // if the 401 or 403 are the results of the cookie being expired, the request will be repeated
                task.response = response
                completionHandler(.allow)
            } else {
                
                // request was successful, URL Session will save cookies we can send the response straight through
                task.delegate.received(response: response)
                completionHandler(.allow)
            }
        } else {
            //URL Session will save cookies we can send the response straight through
            task.delegate.received(response: response)
            completionHandler(.allow)
        }
        
    }
    
    /**
     Makes a synchronous request to the `_session` endpoint to start a session with the server.
     This function will wait 600 seconds
     */
    private func requestCookie(url: URL) {
        
        guard shouldMakeCookieRequest else { return }
        
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/_session"
        
        
        var request = URLRequest(url: components.url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = sessionRequestBody
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = self.session.dataTask(with: request, completionHandler: { (data1, response, error) in
            
            //defer the semaphore.
            defer {semaphore.signal()}
            
            guard let data = data1, let response = response as? HTTPURLResponse, error == nil
                else  {
                    // failed to get the cookie should log something probably.
                    NSLog("Failed to get response from server")
                    return
            }
            
            if response.statusCode / 100 == 2{
            
                do {
                    // Only check for ok:true, https://issues.apache.org/jira/browse/COUCHDB-1356
                    // means we cannot check that the name returned is the one we sent.
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]{
                        if let ok = json["ok"] as? Bool, ok {
                            // everything seems to match up here,
                            // URL Session will save cookies we can send the response straight through
                            NSLog("Cookie request successful")
                        } else {
                            NSLog("ok:true was not present in response dict, despite 2xx status code.")
                        }
                        
                    } else {
                        // we didn't get ok true, but got a successful response odd state, 
                        // probably best to log it and make it so we don't request the cookie again.
                        NSLog("Cookie request failed, response was not a JSON dictionary")
                    }
                    
                } catch {
                    // log the error from the deserialisation, this is an odd state, we should
                    // probably not make cookie request again.
                    NSLog("Failed to deserialise the _session response")
                }
                
            } else if response.statusCode / 100 == 5 {
                NSLog("Received 500 for server for _session reqiest.")
            } else if response.statusCode == 401 {
                // creds error.
                self.shouldMakeCookieRequest = false
                NSLog("Credentials are incorrect, cookie authentication will not be attempted again for this session");
            } else {
                self.shouldMakeCookieRequest = false
                NSLog("Could not get cookie form the server, received status code: \(response.statusCode)")
            }
        })
        task.resume()
        // we should wait for the task to come back before continuting.
        // we also don't really care if it timed out maybe we should?.
        let _ = semaphore.wait(wallTimeout: DispatchWallTime.now() + .seconds(600))
    }

    deinit {
        if !isFirstRequest {
            self.session.finishTasksAndInvalidate()
        }
    }

    private class func userAgent() -> String {
        let processInfo = ProcessInfo.processInfo
        let osVersion = processInfo.operatingSystemVersionString

        #if os(iOS)
            let platform = "iOS"
        #elseif os(OSX)
            let platform = "OSX"
        #elseif os(Linux)
            let platform = "Linux" // Cribbed from Kitura, neeed to see who is running this on Linux
        #else
            let platform = "Unknown";
        #endif

        return "SwiftCloudant/\(CouchDBClient.version)/\(platform)/\(osVersion))"

    }
}

fileprivate extension DispatchTimeInterval {
    static fileprivate func *(interval: DispatchTimeInterval, multiple: Int) -> DispatchTimeInterval {
        switch (interval){
        case .microseconds(let value):
            return .microseconds(value * multiple)
        case .milliseconds(let value):
            return .milliseconds(value * multiple)
        case .nanoseconds(let value):
            return .nanoseconds(value * multiple)
        case .seconds(let value):
            return .seconds(value * multiple)
        case .never:
            return .never
        }
    }
}
