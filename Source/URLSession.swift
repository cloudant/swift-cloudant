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
 A protocol which denotes a HTTP interceptor.
 */
public protocol HTTPInterceptor
{
    /**
     Intercepts the HTTP request. This will only be run once per request.
     - parameter context: the context for the request that is being intercepted.
     - returns: the context for the next request interceptor to use.
     */
    func interceptRequest(in context: HTTPInterceptorContext) -> HTTPInterceptorContext
    /**
     Intercepts the HTTP response. This will only be run once per response.
     - parameter context: the context for the response that is being intercepted.
     - returns: the context for the next response interceptor to use.
     */
    func interceptResponse(in context: HTTPInterceptorContext) -> HTTPInterceptorContext
}

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

// extension that implements default behvaiour, this does have limitations, for example
// only classes can implement HTTPInterceptor due to way polymorphsim is handled.
public extension HTTPInterceptor {

    public func interceptRequest(in context: HTTPInterceptorContext) -> HTTPInterceptorContext {
        return context;
    }

    public func interceptResponse(in context: HTTPInterceptorContext) -> HTTPInterceptorContext {
        return context;
    }
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
    
    internal var requestInterceptors: [HTTPInterceptor]
    
    init(maxRetries: UInt = 10, shouldBackOff:Bool,
         backOffRetries: UInt = 3,
         initialBackOff: DispatchTimeInterval = .milliseconds(250),
         requestInterceptors: [HTTPInterceptor] = []){
        
        self.maxRetries = maxRetries
        self.shouldBackOff = shouldBackOff
        self.backOffRetries = backOffRetries
        self.initialBackOff = initialBackOff
        self.requestInterceptors = requestInterceptors
    }
}

/**
 A class which encapsulates HTTP requests. This class allows requests to be transparently retried.
 */
public class URLSessionTask {
    fileprivate let request: URLRequest
    fileprivate var inProgressTask: URLSessionDataTask
    fileprivate let session: URLSession
    fileprivate var remainingRetries: UInt = 10
    fileprivate var remainingBackOffRetries: UInt = 3
    fileprivate let delegate: InterceptableSessionDelegate

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

    internal lazy var session: URLSession = { () -> URLSession in
        let config = URLSessionConfiguration.default
        #if os(Linux)
            config.httpAdditionalHeaders = ["User-Agent".bridge() : InterceptableSession.userAgent().bridge()]
        #else
            config.httpAdditionalHeaders = [("User-Agent" as NSString) as AnyHashable: InterceptableSession.userAgent()]
        #endif
        return URLSession(configuration: config, delegate: self, delegateQueue: nil) }()
    
    private let interceptors: Array<HTTPInterceptor>

    
    private var taskDict: [Foundation.URLSessionTask: URLSessionTask] = [:]
    
    private let delegateQueue = DispatchQueue(label: "com.cloudant.swift.interceptable.session.delegate", attributes: .concurrent)
    
    private let configuration: InterceptableSessionConfiguration
    
    convenience override init() {
        self.init(delegate: nil, configuration: InterceptableSessionConfiguration(shouldBackOff: false))
        
    }

    /**
     Creates an Interceptable session
     - parameter delegate: a delegate to use for this session.
     - parameter requestInterceptors: Interceptors to use with this session.
     */
    init(delegate: URLSessionDelegate?, configuration: InterceptableSessionConfiguration) {
        interceptors = configuration.requestInterceptors
        self.configuration = configuration
    }

    /**
     Creates a data task to perform the http request.
     - parameter request: the request the task should make
     - parameter delegate: The delegate for the task being created.
     - returns: A `URLSessionTask` representing the task for the `NSURLRequest`
     */
    internal func dataTask(request: URLRequest, delegate: InterceptableSessionDelegate) -> URLSessionTask {
        // create the underlying task.
        var ctx = HTTPInterceptorContext(request: request, response: nil, shouldRetry: false)
        
        for interceptor in interceptors {
            ctx = interceptor.interceptRequest(in: ctx)
        }
        
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
        
        mTask.delegate.completed(error: error)
        // remove the task from the dict so it can be released.
        taskDict.removeValue(forKey: task)
    }
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // yay datas
        guard let task = taskDict[dataTask]
        else {
            // perhaps we should also cancel the task if we fail to look it up.
            return
        }
        
        task.delegate.received(data: data)
    }
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // Retrieve the task from the dict.
        guard let task = taskDict[dataTask], let response = response as? HTTPURLResponse
            else {
                completionHandler(.cancel)
                return
        }
        
        var ctx = HTTPInterceptorContext(request: task.request, response: response, shouldRetry: false)
        for interceptor in self.interceptors {
            ctx = interceptor.interceptResponse(in: ctx)
        }
        
        let deadline: DispatchWallTime
        if let statusCode = ctx.response?.statusCode,
            statusCode == 429 && self.configuration.shouldBackOff && task.remainingBackOffRetries > 0 && task.remainingRetries > 0 {
            task.remainingBackOffRetries -= 1
            
            var backOffTime:DispatchTimeInterval = configuration.initialBackOff
            for _ in 0...(configuration.backOffRetries - task.remainingBackOffRetries ) {
                backOffTime = backOffTime * 2
            }
            deadline = DispatchWallTime.now() + backOffTime
            ctx.shouldRetry = true // make sure we retry.
            
        } else {
            deadline = DispatchWallTime.now()
        }
        
        self.delegateQueue.asyncAfter(wallDeadline: deadline) {
            
            if ctx.shouldRetry  && task.remainingRetries > 0 {
                task.remainingRetries -= 1
                // retry the request.
                ctx = HTTPInterceptorContext(request: task.request, response: nil, shouldRetry: false)
                for interceptor in self.interceptors {
                    ctx = interceptor.interceptRequest(in: ctx)
                }
                self.taskDict.removeValue(forKey: task.inProgressTask)
                task.inProgressTask = self.session.dataTask(with: ctx.request)
                self.taskDict[task.inProgressTask] = task
                task.resume()
                
                completionHandler(.cancel)
            } else {
                // pass the result back to the delegate.
                task.delegate.received(response: response)
                completionHandler(.allow)
            }
        }

        
    }
    
    

    deinit {
        self.session.finishTasksAndInvalidate()
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
        let frameworkBundle = Bundle(for: InterceptableSession.self)
        var bundleDisplayName = frameworkBundle.object(forInfoDictionaryKey: "CFBundleName")
        var bundleVersionString = frameworkBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")

        if bundleDisplayName == nil {
            bundleDisplayName = "SwiftCloudant"
        }
        if bundleVersionString == nil {
            bundleVersionString = "Unknown"
        }

        return "\(bundleDisplayName!)/\(bundleVersionString!)/\(platform)/\(osVersion))"

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
        }
    }
}
