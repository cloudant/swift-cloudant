//
//  CouchOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 03/03/2016.
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
 A enum of errors which could be returned.
 */
enum Errors: ErrorProtocol {
    /**
     Validation of operation settings failed.
     */
    case ValidationFailed

    /**
     The JSON format wasn't what we expected.
     */
    case UnexpectedJSONFormat(statusCode: Int, response: String?)

    /**
     An unexpected HTTP status code (e.g. 4xx or 5xx) was received.
     */
    case HTTP(statusCode: Int, response: String?)
};

/**
 The base class for all operations. This provides a lot of the ground work for interacting with
 NSOperationQueue.
 */
public class CouchOperation: NSOperation, HTTPRequestOperation
{
    // NS operation property overrides

    private var mExecuting: Bool = false
    override public var isExecuting: Bool {
        get {
            return mExecuting
        }
        set {
            if mExecuting != newValue {
                willChangeValue(forKey: "isExecuting")
                mExecuting = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }

    private var mFinished: Bool = false
    override public var isFinished: Bool {
        get {
            return mFinished
        }
        set {
            if mFinished != newValue {
                willChangeValue(forKey: "isFinished")
                mFinished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }

    override public var isAsynchronous: Bool {
        get {
            return true
        }
    }

    var mSession: InterceptableSession? = nil
    var session: InterceptableSession {
        get {
            if let session = mSession {
                return session
            } else {
                mSession = InterceptableSession()
                return mSession!
            }
        }
    }

    var rootURL: NSURL = NSURL()

    public var httpPath: String {
        get {
            return "/"
        }
    }
    public var httpMethod: String {
        get {
            return "GET"
        }
    }

    public var queryItems: [NSURLQueryItem] {
        get {
            return []
        }
    }

    public var httpContentType: String {
        return "application/json"
    }

    // return nil if there is no body
    public var httpRequestBody: NSData? {
        get {
            return nil
        }
    }

    /**
     Sets a completion handler to run when the operation completes.

     - parameter response: - The full deseralised JSON response.
     - parameter httpInfo: - Information about the HTTP response.
     - parameter error: - ErrorProtocol instance with information about an error executing the operation.
     */
    public var completionHandler: ((response: [String: AnyObject]?, httpInfo: HttpInfo?, error: ErrorProtocol?) -> Void)? = nil

    private var executor: OperationRequestExecutor? = nil

    public override init() {
        super.init()
    }

    public func processResponse(data: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?) {
        guard error == nil, let httpInfo = httpInfo
        else {
            self.callCompletionHandler(error: error!)
            return
        }

        do {
            if let data = data {
                let json = try NSJSONSerialization.jsonObject(with: data) as! [String: AnyObject]
                if httpInfo.statusCode / 100 == 2 {
                    self.processResponse(json: json)
                    self.completionHandler?(response: json, httpInfo: httpInfo, error: nil)
                } else {
                    self.completionHandler?(response: json, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: String(data: data, encoding: NSUTF8StringEncoding)))
                }
            } else {
                self.completionHandler?(response: nil, httpInfo: httpInfo, error: Errors.HTTP(statusCode: httpInfo.statusCode, response: nil))
            }
        } catch {
            let response: String?
            if let data = data {
                response = String(data: data, encoding: NSUTF8StringEncoding)
            } else {
                response = nil
            }
            self.completionHandler?(response: nil, httpInfo: httpInfo, error: Errors.UnexpectedJSONFormat(statusCode: httpInfo.statusCode, response: response))
        }

    }

    /**
     This method is called from the
     `processResponse(data: NSData?, httpInfo: HttpInfo?, error: ErrorProtocol?)` method,
     it will contain the deserialized json response in the event the request returned with a
     2xx status code.

     - Note: This should be overridden to trigger other handlers such as a handler for each row of
     a returned view.
     */
    public func processResponse(json: [String: AnyObject]) {
        return
    }

    /**
     Calls the completion handler for the operation with the specified error.
     Subclasses need to override this to call the completion handler they have defined.
     */
    public func callCompletionHandler(error: ErrorProtocol) {
        self.completionHandler?(response: nil, httpInfo: nil, error: error)
    }

    /**
     Validates the operation has been set up correctly, subclasses should override but call and
     use the result of the super class implementation.
     */
    public func validate() -> Bool {
        return true
    }

    /**
     This should be used to serialise any data into the format expected by the CouchDB/Cloudant
     endpoint.

     - throws: An error in the event of a failure to serialise.
     - note: This is guranteed to be  called after `validate() -> Bool` and before the
     `HTTPRequestOperation` properties are computed.
     */
    public func serialise() throws {

    }

    final override public func start() {
        do {
            // Always check for cancellation before launching the task
            if isCancelled {
                isFinished = true
                return
            }

            if !self.validate() {
                self.callCompletionHandler(error: Errors.ValidationFailed)
                isFinished = true
                return
            }

            try self.serialise()

            // start the operation
            isExecuting = true
            executor = OperationRequestExecutor(operation: self)
            executor?.executeRequest()
        } catch {
            self.callCompletionHandler(error: error)
            isFinished = true
        }
    }

    final func completeOperation() {
        self.executor = nil // break the cycle.
        self.isExecuting = false
        self.isFinished = true
    }

    final override public func cancel() {
        super.cancel()
        self.executor?.cancel()
    }

}
