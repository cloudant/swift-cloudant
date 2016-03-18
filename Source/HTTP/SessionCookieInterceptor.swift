//
//  SessionCookieInterceptor.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 28/02/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation


public struct SessionCookieInterceptor : HTTPInterceptor
{
    
    private let sessionCookieTimeout:Int64 = 600
    private let sessionRequestBody:NSData
    private var shouldMakeSessionRequest:Bool = true
    private var cookie:String?
    private let urlSession:InterceptableSession
    
    
    init(username:String, password:String){
        let encodedUsername = username.stringByAddingPercentEncodingWithAllowedCharacters
        let encodedPassword = password.stringByAddingPercentEncodingWithAllowedCharacters
        
        let payload = "name=\(encodedUsername)&password=\(encodedPassword)"
        
        sessionRequestBody = payload.dataUsingEncoding(NSASCIIStringEncoding)!
        urlSession = InterceptableSession()
  
    }
    
    public mutating func interceptResponse(var ctx: HTTPInterceptorContext) -> HTTPInterceptorContext {
        
        guard let response = ctx.response
        else {
            return ctx;
        }
        
        if response.statusCode == 403 || response.statusCode == 401 {
            ctx.shouldRetry = true
            self.cookie = nil
        } else if let cookieHeader = response.allHeaderFields["Set-Cookie"] as? String {
            cookie = cookieHeader.componentsSeparatedByString(";").first
        }
        
        return ctx;
    }
    
    
    public mutating func interceptRequest(ctx: HTTPInterceptorContext) -> HTTPInterceptorContext {
        // if we shouldn't make the request just return th ctx
        guard shouldMakeSessionRequest
            else {
                return ctx
        }
        
        if let cookie = self.cookie {
            //apply the coode
            ctx.request.setValue(cookie, forHTTPHeaderField: "Cookie")
        } else {
            // get the new cookie and apply it
            self.cookie = self.startNewSession(ctx.request.URL!)
            if let cookie = self.cookie {
                ctx.request.setValue(cookie, forHTTPHeaderField: "Cookie")
            }
        }
        
        return ctx
    }
    
    
    private mutating func startNewSession(url:NSURL) -> String? {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
        components.path = "/_session"
        
        let request = NSMutableURLRequest(URL: components.URL!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = self.sessionRequestBody
        
        
        let semaphore = dispatch_semaphore_create(0)
        var cookie:String?
        
        let task = self.urlSession.dataTask(request) { (data, response, error) -> Void in
            
            //defer semaphore
            defer { dispatch_semaphore_signal(semaphore) }
            
            let response = response as? NSHTTPURLResponse
            
            if let error = error {
                //Network failure, often transient, try again next time around.
                NSLog("Error making cookie response, error \(error.localizedDescription)");
            }
            
            if let response = response {
                //we have a response
                
                if response.statusCode / 100 == 2 {
                    //success
                    
                    guard let data = data
                        else {
                            NSLog("No data from response, bailing")
                            return;
                    }
                    
                    //Check data sent back before attempting to get the cookie from the headers.
                    do {
                        let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                        
                        // Only check for ok:true, https://issues.apache.org/jira/browse/COUCHDB-1356
                        // means we cannot check that the name returned is the one we sent.
                        guard let ok = jsonResponse.objectForKey("ok") as? NSNumber where
                            ok.boolValue
                            else {
                                NSLog("Response did not contain ok:true, bailing")
                                return
                        }
                        
                        guard let cookieHeader = response.allHeaderFields["Set-Cookie"] as? String
                            else {
                                // log error and return
                                NSLog("Cookie header was no present or could not be parsed.")
                                return
                        }
                        
                        cookie = cookieHeader.componentsSeparatedByString(";").first

                    } catch {
                        // log it and error out.
                        NSLog("Failed to deserialise data as json, error: \(error)")
                    }
                    
                } else if response.statusCode == 401 {
                    // Creds invalid, fail don't retry.
                    // Credentials are not valid, fail and don't retry.
                    NSLog("Credentials are incorrect, cookie authentication will not be attempted again by this interceptor");
                    self.shouldMakeSessionRequest = false
                } else if response.statusCode / 100 == 5 {
                    // Server error of some kind; often transient. Try again next time.
                    NSLog("Failed to get cookie from the server, response code was \(response.statusCode).")
                } else {
                    // Most other HTTP status codes are non-transient failures; don't retry.
                    NSLog("Failed to get cookie from the server,response code \(response.statusCode). Cookie authentication will not be attempted again by this interceptor object");
                    self.shouldMakeSessionRequest = false
                }
 
            }
        }
        
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, self.sessionCookieTimeout * Int64(NSEC_PER_SEC)))
        
        
        return cookie
        
        
        
    }
    
    
    
}