//
//  CouchOperation.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
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
    
    var httpPath:String {
        get {
            return "/"
        }
    }
    var httpMethod : String {
        get {
            return "GET"
        }
    }
    
    var queryItems:[NSURLQueryItem] {
        get {
            return []
        }
    }
    
    //return nil if there is no body
    var httpRequestBody:NSData? {
        get {
            return nil
        }
    }
    
    private var executor:OperationRequestExecutor? = nil
    
    override init() {
        super.init()
    }

    
    // subclasses should override
    func processResponse(data:NSData?, statusCode:Int, error:ErrorType?){
        
    }
    
    func callCompletionHandler(error:ErrorType){
        return
    }
    
    func validate() -> Bool {
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