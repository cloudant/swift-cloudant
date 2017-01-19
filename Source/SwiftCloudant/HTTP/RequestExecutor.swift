//
//  RequestExecutor.swift
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
 Contains HTTP response information.
 */
public struct HTTPInfo {
    /**
     The status code of the HTTP request.
     */
    public let statusCode: Int
    /**
     The headers that were returned by the server.
     */
    public let headers: [String: String]
}

/**
 Executes a `HTTPRequestOperation`'s HTTP request.
 */
class OperationRequestExecutor: InterceptableSessionDelegate {

    /**
     The HTTP task currently processing
     */
    var task: URLSessionTask?
    /**
     The operation which this OperationRequestExecutor is Executing.
     */
    let operation: HTTPRequestOperation
    
    var buffer: Data
    var response: HTTPURLResponse?
    /**
     Creates an OperationRequestExecutor.
     - parameter operation: The operation that this OperationRequestExecutor will execute
     */
    init(operation: HTTPRequestOperation) {
        self.operation = operation
        task = nil
        buffer = Data()
    }
    
    func received(data: Data) {
        // This class doesn't support streaming of data
        // so we buffer until the request completes 
        // and then we will deliver it to the
        // operation in chunk.
        buffer.append(data)
    }
    
    func received(response: HTTPURLResponse) {
        // Store the response to deliver with the data when the task completes.
        self.response = response
    }
    
    func completed(error: Error?) {
        self.task = nil // allow task to be deallocated.
        
        // task has completed, handle the operation canceling etc.
        if self.operation.isCancelled {
            self.operation.completeOperation()
            return
        }
        
        let httpInfo: HTTPInfo?
        
        if let response = response {
                var headers:[String: String] = [:]
                for (key, value) in response.allHeaderFields {
                    headers["\(key)"] = "\(value)"
                }
                httpInfo = HTTPInfo(statusCode: response.statusCode, headers: headers)
        } else {
            httpInfo = nil
        }
        
        self.operation.processResponse(data: buffer, httpInfo: httpInfo, error: error)
        self.operation.completeOperation()

    }

    /**
     Executes the HTTP request for the operation held in the `operation` property
     */
    func executeRequest () {

        do {
            let builder = OperationRequestBuilder(operation: self.operation)
            let request = try builder.makeRequest()

            self.task = self.operation.session.dataTask(request: request, delegate: self)
            self.task?.resume()
        } catch {
            self.operation.processResponse(data: nil, httpInfo: nil, error: error)
            self.operation.completeOperation()
        }

    }

    /**
     Cancels the currently processing HTTP task.
     */
    func cancel() {
        if let task = task {
            task.cancel()
        }
    }

}
