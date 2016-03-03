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
    
    
    var session:InterceptableSession
    
    var rootURL:NSURL = NSURL()
    
    var httpPath:String = "/"
    var httpMethod : String = "GET"
    
    var queryItems:[NSURLQueryItem] = []
    
    //return nil if there is no body
    var httpRequestBody:NSData? = nil
    
    init(httpSession:InterceptableSession) {
        self.session = httpSession
        super.init()
    }
    
    
    func completeOpetation(){
        self.willChangeValueForKey("isFinished")
        self.willChangeValueForKey("isExecuting")
        
        self.executing = false
        self.finished = true
        
        self.didChangeValueForKey("isExecuting")
        self.didChangeValueForKey("isFinished")
    }
    
    func processResponse(data:NSData?, statusCode:Int, error:ErrorType?){
        
    }
    
    func callCompletionHandler(error:ErrorType){
        
    }
    
    override public func start() {
        super.start()
        // TODO implement start function.
    }
    
    override public func cancel() {
        super.cancel()
        // TODO cancel the request
    }
    
    
    
    
}