//
//  URLSession.swft
//  ObjectiveCloudant
//
//  Created by Rhys Short on 28/02/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation



public protocol HTTPInterceptor
{
    func interceptRequest(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext
    func interceptResponse(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext
}

public extension HTTPInterceptor {
    
    public func interceptRequest(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext {
        return ctx;
    }
    
    public func interceptResponse(ctx:HTTPInterceptorContext) -> HTTPInterceptorContext {
        return ctx;
    }
}

public struct HTTPInterceptorContext {
    let request:NSMutableURLRequest
    let response: NSHTTPURLResponse?
    var shouldRetry:Bool = false
}

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
                return .Suspended
            }
        }
    }
    
    init(session:NSURLSession, request:NSURLRequest, interceptors:Array<HTTPInterceptor>, completionHandler:(NSData?, NSURLResponse?, NSError?) -> (Void)){
        self.interceptors = interceptors
        self.request = request
        self.session = session
        self.completionHandler = completionHandler
    }
    
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
    
    public func cancel() {
        if let task = self.inProgessTask {
            task.cancel()
        }
    }
    
    
    private func makeRequest() -> NSURLSessionDataTask {
        var ctx = HTTPInterceptorContext(request: request.mutableCopy() as! NSMutableURLRequest, response: nil, shouldRetry: false)
        
        for interceptor in interceptors {
            ctx = interceptor.interceptRequest(ctx)
        }
        
        return self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            guard error == nil
            else {
                self.completionHandler(data,response,error)
                return
            }
            
            ctx = HTTPInterceptorContext(request: ctx.request, response: (response as! NSHTTPURLResponse), shouldRetry: ctx.shouldRetry)
            
            for interceptor in self.interceptors {
                ctx = interceptor.interceptResponse(ctx)
            }
            
            if ctx.shouldRetry && self.remainingRetries > 0 {
                self.remainingRetries--;
                self.inProgessTask = self.makeRequest()
                self.inProgessTask?.resume()
            } else {
                //call completion
                self.completionHandler(data,response,error)
            }
        })
    }
    
    
}

public class InterceptableSession {
    
    
    private let session:NSURLSession
    private let interceptors:Array<HTTPInterceptor>
    
    
    convenience init(){
        self.init(delegate: nil,requestInterceptors: [])
    }
    
    init(delegate:NSURLSessionDelegate?, requestInterceptors:Array<HTTPInterceptor>){
        interceptors = requestInterceptors
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["User-Agent":InterceptableSession.userAgent()]
        session = NSURLSession(configuration: config,delegate:delegate, delegateQueue: nil)
    }
    
    
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
            let platform = "Unkown";
        #endif
        
        let frameworkBundle = NSBundle(forClass: InterceptableSession.self)
        let bundleDisplayName = frameworkBundle.objectForInfoDictionaryKey("CFBundleName")
        let bundleVersionString = frameworkBundle.objectForInfoDictionaryKey("CFBundleShortVersionString")
        
        return "\(bundleDisplayName)/\(bundleVersionString) (\(platform), \(osVersion))"
    }
    
    
}