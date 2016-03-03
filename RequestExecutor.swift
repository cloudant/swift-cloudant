//
//  RequestExecutor.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
//

import Foundation



class OperationRequestExecutor {
    
    var task : URLSessionTask?
    let operation : HTTPRequestOperation
    
    init(operation:HTTPRequestOperation){
        self.operation = operation
        task = nil
    }
    
    func executeRequest (){
        
        let builder = OperationRequestBuilder(operation: self.operation)
        let request = builder.buildRequest()
        
        self.task = self.operation.session.dataTask(request, completionHandler: { (data, response, error) -> Void in
            
            // Should break the retain cycle but not sure.
            self.task = nil
            
            if self.operation.cancelled {
                self.operation.completeOpetation()
                return
            }
            
            
            let statusCode: Int
            
            if let response = response as? NSHTTPURLResponse {
                statusCode = response.statusCode
            } else {
                statusCode = -1
            }
            
            self.operation.processResponse(data, statusCode: statusCode, error: error)
            self.operation.completeOpetation()
        
        })
        
        self.task?.resume()
        
    }
    
    func cancel(){
        if let task = task {
            task.cancel()
        }
    }
    
    
}