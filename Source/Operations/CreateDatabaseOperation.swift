//
//  CreateDatabaseOperation.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation


public class CreateDatabaseOperation : CouchOperation {
    
    public var databaseName:String? = nil
    
    override public var httpMethod:String {
        get {
            return "PUT"
        }
    }
    
    public override var httpPath:String {
        get {
            // Safe to foce unwrap validation would fail if this is nil
            return "/\(self.databaseName!)"
        }
    }
    
    public var createDatabaseCompletionBlock : ((statusCode:Int?, operationError:ErrorType?) -> Void)? = nil
    
    
    public override func validate() -> Bool {
        return super.validate() && self.databaseName != nil // should work iirc
    }
    
    override public func callCompletionHandler(error: ErrorType) {
        self.createDatabaseCompletionBlock?(statusCode: nil, operationError: error)
    }
    
    public override func processResponse(data: NSData?, statusCode: Int, error: ErrorType?) {
        guard error == nil
        else  {
            self.callCompletionHandler(error!)
            return
        }
        
        if statusCode == 201 || statusCode ==  202 {
            /// success!
            self.createDatabaseCompletionBlock?(statusCode: statusCode, operationError: nil)
        } else {
            callCompletionHandler(Errors.CreateDatabaseFailed)
        }
    }

}