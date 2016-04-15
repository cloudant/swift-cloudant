//
//  RequestExecutor.swift
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
        
        self.task = self.operation.session.dataTask(request: request, completionHandler: { (data, response, error) -> Void in
            
            // Should break the retain cycle but not sure.
            self.task = nil
            
            if self.operation.isCancelled {
                self.operation.completeOpetation()
                return
            }
            
            
            let statusCode: Int
            
            if let response = response as? NSHTTPURLResponse {
                statusCode = response.statusCode
            } else {
                statusCode = -1
            }
            
            self.operation.processResponse(data: data, statusCode: statusCode, error: error)
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