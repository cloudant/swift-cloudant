//
//  SessionCookieInterceptor.swift
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
 An `HTTPInterceptor` which performs session cookie authentication with the
 CouchDB / Cloudant instance
 */
public class SessionCookieInterceptor: HTTPInterceptor
{
    /**
     The time to wait to retrieve a cookie from the server.
     */
    let sessionCookieTimeout: Int64 = 600
    /**
     The requestBody to use when performing HTTP requests to the `_session` endpoint.
     */
    let sessionRequestBody: Data
    /**
     Determines if the `_session` request should be made
     */
    var shouldMakeSessionRequest: Bool = true
    /**
     The cookie retrieved from the server
     */
    var cookie: String?
    /**
     The `NSURLSession` to use when making HTTP requests.
     */
    let urlSession: URLSession

    convenience init(username: String, password: String) {
        self.init(username: username,
                  password: password,
                  session: URLSession(configuration: URLSessionConfiguration.ephemeral))
    }
    
    init(username: String, password: String, session: URLSession){
        let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
        let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
        
        let payload = "name=\(encodedUsername)&password=\(encodedPassword)"
        sessionRequestBody = payload.data(using: .ascii)!
        self.urlSession = session
    }

    public func interceptResponse(in context: HTTPInterceptorContext) -> HTTPInterceptorContext {

        guard let response = context.response
        else {
            return context;
        }

        var ctx = context
            if response.statusCode == 403 || response.statusCode == 401 {
                ctx.shouldRetry = true
                self.cookie = nil
            } else if let cookieHeader = response.allHeaderFields["Set-Cookie"] as? String {
                cookie = cookieHeader.components(separatedBy: ";").first
            }
        return ctx;
    }

    public func interceptRequest(in context: HTTPInterceptorContext) -> HTTPInterceptorContext {
        // if we shouldn't make the request just return th ctx
        guard shouldMakeSessionRequest
        else {
            return context
        }
        var ctx = context
        if let cookie = self.cookie {
            // apply the coode
            ctx.request.setValue(cookie, forHTTPHeaderField: "Cookie")
        } else {
            // get the new cookie and apply it
            self.cookie = self.startNewSession(url: ctx.request.url!)
            if let cookie = self.cookie {
                ctx.request.setValue(cookie, forHTTPHeaderField: "Cookie")
            }
        }

        return ctx
    }

    private func startNewSession(url: URL) -> String? {
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/_session"

        var request = URLRequest(url: components.url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = self.sessionRequestBody

        let semaphore = DispatchSemaphore(value: 0)
        
        var cookie: String?
 
        let task = self.urlSession.dataTask(with: request) { (data, response, error) -> Void in

            // defer semaphore
            defer { semaphore.signal() }

            let response = response as? HTTPURLResponse

            if let error = error {
                // Network failure, often transient, try again next time around.
                NSLog("Error making cookie response, error \(error.localizedDescription)");
            }

            if let response = response {
                // we have a response

                if response.statusCode / 100 == 2 {
                    // success

                    guard let data = data
                    else {
                        NSLog("No data from response, bailing")
                        return;
                    }

                    // Check data sent back before attempting to get the cookie from the headers.
                    do {

                        // Only check for ok:true, https://issues.apache.org/jira/browse/COUCHDB-1356
                        // means we cannot check that the name returned is the one we sent.
                        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let ok = jsonResponse["ok"] as? NSNumber,
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

                        cookie = cookieHeader.components(separatedBy: ";").first

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
        task.resume()
//        TODO wait on sempahore with timeout that mimics the swift 3 pre preview 1 code.
//        semaphore.wait(timeout: DispatchTime.now(dispatch_time_t(DispatchTime.now, self.sessionCookieTimeout * Int64(NSEC_PER_SEC)))
        semaphore.wait()

        return cookie

    }

}
