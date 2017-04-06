//
//  Operation.swift
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
 An NSOperation subclass for executing `CouchOperations`
 */
public class Operation: Foundation.Operation, HTTPRequestOperation
{
    
    /**
     A enum of errors which could be returned.
     */
    enum Error: Swift.Error {
        /**
         Validation of operation settings failed.
         */
        case validationFailed
        
        /**
         The JSON format wasn't what we expected.
         */
        case unexpectedJSONFormat(statusCode: Int, response: String?)
        
        /**
         An unexpected HTTP status code (e.g. 4xx or 5xx) was received.
         */
        case http(statusCode: Int, response: String?)
    };
    
    private let couchOperation: CouchOperation
    
    /**
     Initalises an Operation for executing.
     
     - parameter couchOperation: The `CouchOperation` to execute.
     */
    public init(couchOperation: CouchOperation) {
        self.couchOperation = couchOperation
    }
    
    
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
    internal var session: InterceptableSession {
        get {
            if let session = mSession {
                return session
            } else {
                mSession = InterceptableSession()
                return mSession!
            }
        }
    }

    internal var rootURL: URL = URL(string: "http://cloudant.invalid")!

    internal var httpPath: String {
        return couchOperation.endpoint
    }
    internal var httpMethod: String {
        return couchOperation.method
    }

    internal var queryItems: [URLQueryItem] {
        get {
            var items:[URLQueryItem] = []
            
            for (key, value) in couchOperation.parameters {
                items.append(URLQueryItem(name: key, value: value))
            }
            return items
        }
    }

    internal var httpContentType: String {
        return couchOperation.contentType
    }

    // return nil if there is no body
    internal var httpRequestBody: Data? {
        return couchOperation.data
    }

    internal var executor: OperationRequestExecutor? = nil

    internal func processResponse(data: Data?, httpInfo: HTTPInfo?, error: Swift.Error?) {
        couchOperation.processResponse(data: data, httpInfo: httpInfo, error: error)
    }

    final override public func start() {
        do {
            // Always check for cancellation before launching the task
            if isCancelled {
                isFinished = true
                return
            }

            if !couchOperation.validate() {
                couchOperation.callCompletionHandler(error: Error.validationFailed)
                isFinished = true
                return
            }

            try couchOperation.serialise()

            // start the operation
            isExecuting = true
            executor = OperationRequestExecutor(operation: self)
            executor?.executeRequest()
        } catch {
            couchOperation.callCompletionHandler(error: error)
            isFinished = true
        }
    }

    final public func completeOperation() {
        self.executor = nil // break the cycle.
        self.isExecuting = false
        self.isFinished = true
    }

    final override public func cancel() {
        super.cancel()
        self.executor?.cancel()
    }

}
