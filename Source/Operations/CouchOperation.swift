//
//  CouchOperation.swift
//  ObjectiveCloudant
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

enum Errors : ErrorType {
    /**
    Creating a database failed.
    */
    case CreateDatabaseFailed
    /**
    Deleting a database failed.
    */
    case DeleteDatabaseFailed
    /**
    Validation of operation settings failed.
    */
    case ValidationFailed
    /**
    Deleting a Query index failed.
    */
    case DeleteQueryIndexFailed
    /**
    Creating a Query index failed.
    */
    case CreateQueryIndexFailed
    /**
    Getting a document failed.
    */
    case GetDocumentFailed
    /**
    Creating or updating a document failed.
    */
    case CreateUpdateDocumentFailed
    /**
    Deleting a document failed.
    */
    case DeleteDocumentFailed
    /**
    Finding documents failed.
    */
    case FindDocumentsFailed
    /**
     The JSON format wasn't what we expected.
     */
    case UnexpectedJSONFormat
};

public class CouchOperation : NSOperation, HTTPRequestOperation
{
    // NS operation property overrides
    
    private var mExecuting: Bool = false
    override public var executing: Bool {
        get {
            return mExecuting
        }
        set {
            if mExecuting != newValue {
                willChangeValueForKey("isExecuting")
                mExecuting = newValue
                didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var mFinished:Bool = false
    override public var finished : Bool {
        get {
            return mFinished
        }
        set {
            if mFinished != newValue {
                willChangeValueForKey("isFinished")
                mFinished = newValue
                didChangeValueForKey("isFinished")
            }
        }
    }
    
    override public var asynchronous : Bool {
        get {
            return true
        }
    }
    
    
    var mSession : InterceptableSession? = nil
    var session:InterceptableSession {
        get {
            if let session = mSession {
                return session
            } else {
                mSession = InterceptableSession()
                return mSession!
            }
        }
    }
    
    var rootURL:NSURL = NSURL()
    
    public var httpPath:String {
        get {
            return "/"
        }
    }
    public var httpMethod : String {
        get {
            return "GET"
        }
    }
    
    public var queryItems:[NSURLQueryItem] {
        get {
            return []
        }
    }
    
    //return nil if there is no body
    public var httpRequestBody:NSData? {
        get {
            return nil
        }
    }
    
    private var executor:OperationRequestExecutor? = nil
    
    public override init() {
        super.init()
    }

    
    // subclasses should override
    public func processResponse(data:NSData?, statusCode:Int, error:ErrorType?){
        
    }
    
    public func callCompletionHandler(error:ErrorType){
        return
    }
    
    public func validate() -> Bool {
        return true
    }
    
    final override public func start() {
        // Always check for cancellation before launching the task
        if cancelled {
            finished = true
            return
        }
        
        if !self.validate() {
            self.callCompletionHandler(Errors.ValidationFailed)
            finished = true
            return
        }
        
        // start the operation
        executing = true
        executor = OperationRequestExecutor(operation: self)
        executor?.executeRequest()
    }
    
    final func completeOpetation(){
        self.executing = false
        self.finished = true
    }
    
    final override public func cancel() {
        super.cancel()
        self.executor?.cancel()
    }
    
    
    
    
}