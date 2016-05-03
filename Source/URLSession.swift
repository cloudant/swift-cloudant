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


/**
 A protocol which denotes a HTTP interceptor.
 */
public protocol HTTPInterceptor
{
    /**
     Intercepts the HTTP request. This will only be run once per request.
     - parameter ctx: the context for the request that is being intercepted.
     - returns: the context for the next request interceptor to use.
     */
    func interceptRequest(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext
    /**
     Intercepts the HTTP response. This will only be run once per response.
     - parameter ctx: the context for the response that is being intercepted.
     - returns: the context for the next response interceptor to use.
     */
    func interceptResponse(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext
}

// extension that implements default behvaiour, this does have limitations, for example
// only classes can implement HTTPInterceptor due to way polymorphsim is handled.
public extension HTTPInterceptor {
    
    public func interceptRequest(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext {
        return ctx;
    }
    
    public func interceptResponse(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext {
        return ctx;
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
    let request:NSMutableURLRequest
    /** 
     The response that was received from the server. This will be `nil` if the request errored
     or has not yet been made.
     */
    let response: NSHTTPURLResponse?
    /**
    A flag that signals to the HTTP layer that it should retry the request.
    */
    var shouldRetry:Bool = false
}

/**
 A class which encapsulates HTTP requests. This class allows requests to be transparently retried.
 */
public class URLSessionTask {
    private let request:NSURLRequest
    private var inProgessTask: NSURLSessionDataTask?
    private let session:NSURLSession
    private var remainingRetries:Int = 10
    private let interceptors:Array<HTTPInterceptor>
    private let completionHandler: (NSData?, NSURLResponse?, NSError?) -> (Void)
    
    public var state:NSURLSessionTaskState {
        get {
            if let task = self.inProgessTask {
                return task.state
            } else {
                return .suspended
            }
        }
    }
    
    /**
     Creates a URLSessionTask object
     - parameter session: the NSURLSession it should use when making HTTP requests.
     - parameter request: the HTTP request to make
     - parameter interceptors: the HTTP interceptors to run for the request.
     - parameter completionHandler: The block to run when the task has completed.
     */
    init(session:NSURLSession, request:NSURLRequest, interceptors:Array<HTTPInterceptor>, completionHandler:(NSData?, NSURLResponse?, NSError?) -> (Void)){
        self.interceptors = interceptors
        self.request = request
        self.session = session
        self.completionHandler = completionHandler
    }
    
    /**
        Resumes a suspended task
     */
    public func resume(){
        if let task = inProgessTask {
            task.resume();
        }else {
            //make task and start
            let task = self.makeRequest()
            self.inProgessTask = task
            task.resume()
        }
    }
    
    /**
        Cancels the task.
    */
    public func cancel() {
        if let task = self.inProgessTask {
            task.cancel()
        }
    }
    
    
    private func makeRequest() -> NSURLSessionDataTask {
        var ctx = HTTPInterceptorContext(request: request.mutableCopy() as! NSMutableURLRequest, response: nil, shouldRetry: false)
        
        for interceptor in interceptors {
            ctx = interceptor.interceptRequest(ctx: ctx)
        }
        
        return self.session.dataTask(with:request, completionHandler: { (data, response, error) -> Void in
            
            guard error == nil
            else {
                self.completionHandler(data,response,error)
                return
            }
            
            ctx = HTTPInterceptorContext(request: ctx.request, response: (response as! NSHTTPURLResponse), shouldRetry: ctx.shouldRetry)
            
            for interceptor in self.interceptors {
                ctx = interceptor.interceptResponse(ctx:ctx)
            }
            
            if ctx.shouldRetry && self.remainingRetries > 0 {
                self.remainingRetries -= 1;
                self.inProgessTask = self.makeRequest()
                self.inProgessTask?.resume()
            } else {
                //call completion
                self.completionHandler(data,response,error)
            }
        })
    }
    
    
}

/**
 A class to create `URLSessionTask`
 */
public class InterceptableSession {
    
    
    private let session:NSURLSession
    private let interceptors:Array<HTTPInterceptor>
    
    
    convenience init(){
        self.init(delegate: nil,requestInterceptors: [])
    }
    
    /**
     Creates an Interceptable session
     - parameter delegate: a delegate to use for this session.
     - parameter requestInterceptors: Interceptors to use with this session.
     */
    init(delegate:NSURLSessionDelegate?, requestInterceptors:Array<HTTPInterceptor>){
        interceptors = requestInterceptors
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.httpAdditionalHeaders = ["User-Agent":InterceptableSession.userAgent()]
        session = NSURLSession(configuration: config,delegate:delegate, delegateQueue: nil)
    }
    
    /**
        Creates a data task to perform the http request.
        - parameter request: the request the task should make
        - parameter completionHandler: A block to call when the task is completed.
        - returns: A `URLSessionTask` representing the task for the `NSURLRequest`
     */
    public func dataTask(request:NSURLRequest, completionHandler:(NSData?, NSURLResponse?, NSError?) -> Void ) -> URLSessionTask
    {
        return URLSessionTask(session: session, request: request, interceptors: interceptors, completionHandler: completionHandler)
    }
    
    deinit {
        self.session.finishTasksAndInvalidate()
    }
    
    private class func userAgent() -> String {
        let processInfo = NSProcessInfo.processInfo()
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
        let frameworkBundle = NSBundle(for: InterceptableSession.self)
        var bundleDisplayName = frameworkBundle.objectForInfoDictionaryKey("CFBundleName")
        var bundleVersionString = frameworkBundle.objectForInfoDictionaryKey("CFBundleShortVersionString")
        
        if bundleDisplayName == nil {
            bundleDisplayName = "SwiftCloudant"
        }
        if bundleVersionString == nil {
            bundleVersionString = "Unknown"
        }
        
        return "\(bundleDisplayName!)/\(bundleVersionString!)/\(platform)/\(osVersion))"
        
    }
    
    
}