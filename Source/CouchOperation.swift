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

/**
 A enum of errors which could be returned.
 */
enum Errors : ErrorProtocol {
    /**
    Creating a database failed.
    */
    case CreateDatabaseFailed(statusCode:Int, jsonResponse:String?)
    /**
    Deleting a database failed.
    */
    case DeleteDatabaseFailed(statusCode:Int, jsonResponse:String?)
    /**
    Validation of operation settings failed.
    */
    case ValidationFailed
    /**
    Deleting a Query index failed.
    */
    case DeleteQueryIndexFailed(statusCode:Int, jsonResponse:String?)
    /**
    Creating a Query index failed.
    */
    case CreateQueryIndexFailed(statusCode:Int, jsonResponse:String?)
    /**
    Getting a document failed.
    */
    case GetDocumentFailed(statusCode:Int, jsonResponse:String?)
    /**
    Creating or updating a document failed.
    */
    case CreateUpdateDocumentFailed(statusCode:Int, jsonResponse:String?)
    /**
    Deleting a document failed.
    */
    case DeleteDocumentFailed(statusCode:Int, jsonResponse:String?)
    /**
    Finding documents failed.
    */
    case FindDocumentsFailed(statusCode:Int, jsonResponse:String?)
    /**
     The JSON format wasn't what we expected.
     */
    case UnexpectedJSONFormat(statusCode:Int, response:String?)
};

/**
 The base class for all operations. This provides a lot of the ground work for interacting with
 NSOperationQueue.
 */
public class CouchOperation : NSOperation, HTTPRequestOperation
{
    // NS operation property overrides
    
    private var mExecuting: Bool = false
    override public var isExecuting: Bool {
        get {
            return mExecuting
        }
        set {
            if mExecuting != newValue {
                willChangeValue(forKey:"isExecuting")
                mExecuting = newValue
                didChangeValue(forKey:"isExecuting")
            }
        }
    }
    
    private var mFinished:Bool = false
    override public var isFinished : Bool {
        get {
            return mFinished
        }
        set {
            if mFinished != newValue {
                willChangeValue(forKey:"isFinished")
                mFinished = newValue
                didChangeValue(forKey:"isFinished")
            }
        }
    }
    
    override public var isAsynchronous : Bool {
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

    public func processResponse(data:NSData?, statusCode:Int, error:ErrorProtocol?){
        
    }
    
    /**
     Calls the completion handler for the operation with the specified error.
     Subclasses need to override this to call the completion handler they have defined.
     */
    public func callCompletionHandler(error:ErrorProtocol){
        return
    }
    
    /**
     Validates the operation has been set up correctly, subclasses should override but call and 
     use the result of the super class implementation.
    */
    public func validate() -> Bool {
        return true
    }
    
    final override public func start() {
        // Always check for cancellation before launching the task
        if isCancelled {
            isFinished = true
            return
        }
        
        if !self.validate() {
            self.callCompletionHandler(error:Errors.ValidationFailed)
            isFinished = true
            return
        }
        
        // start the operation
        isExecuting = true
        executor = OperationRequestExecutor(operation: self)
        executor?.executeRequest()
    }
    
    final func completeOperation(){
        self.isExecuting = false
        self.isFinished = true
    }
    
    final override public func cancel() {
        super.cancel()
        self.executor?.cancel()
    }
    
    
    
    
}