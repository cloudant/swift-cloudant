//
//  DeleteDatabaseOperation.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation


public class DeleteDatabaseOperation : CouchOperation {
    
    var databaseName:String? = nil
    
    override var httpMethod:String {
        get {
            return "DELETE"
        }
    }
    
    override var httpPath:String {
        get {
            // Safe to foce unwrap validation would fail if this is nil
            return "/\(self.databaseName!)"
        }
    }
    
    var deleteDatabaseCompletionBlock : ((statusCode:Int?, operationError:ErrorType?) -> Void)? = nil
    
    
    override func validate() -> Bool {
        return super.validate() && self.databaseName != nil // should work iirc
    }
    
    override func callCompletionHandler(error: ErrorType) {
        self.deleteDatabaseCompletionBlock?(statusCode: nil, operationError: error)
    }
    
    override func processResponse(data: NSData?, statusCode: Int, error: ErrorType?) {
        guard error == nil
            else  {
                self.callCompletionHandler(error!)
                return
        }
        
        if statusCode == 200 || statusCode ==  202 { //Couch could return accepted instead of ok.
            /// success!
            self.deleteDatabaseCompletionBlock?(statusCode: statusCode, operationError: nil)
        } else {
            callCompletionHandler(Errors.CreateDatabaseFailed)
        }
    }
    
}