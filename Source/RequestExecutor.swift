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
public struct HttpInfo {
    /**
     The status code of the HTTP request.
     */
    let statusCode: Int
    /**
     The headers that were returned by the server.
     */
    let headers: [String: String]
}

/**
 Executes a `HTTPRequestOperation`'s HTTP request.
 */
class OperationRequestExecutor {

    /**
     The HTTP task currently processing
     */
    var task: URLSessionTask?
    /**
     The operation which this OperationRequestExecutor is Executing.
     */
    let operation: HTTPRequestOperation
    /**
     Creates an OperationRequestExecutor.
     - parameter operation: The operation that this OperationRequestExecutor will execute
     */
    init(operation: HTTPRequestOperation) {
        self.operation = operation
        task = nil
    }

    /**
     Executes the HTTP request for the operation held in the `operation` property
     */
    func executeRequest () {

        do {
            let builder = OperationRequestBuilder(operation: self.operation)
            let request = try builder.buildRequest()

            self.task = self.operation.session.dataTask(request: request, completionHandler: { (data, response, error) -> Void in

                // Should break the retain cycle but not sure.
                self.task = nil

                if self.operation.isCancelled {
                    self.operation.completeOperation()
                    return
                }

                let httpInfo: HttpInfo?

                if let response = response as? NSHTTPURLResponse {
                    httpInfo = HttpInfo(statusCode: response.statusCode, headers: response.allHeaderFields as! [String: String])
                } else {
                    httpInfo = nil
                }

                self.operation.processResponse(data: data, httpInfo: httpInfo, error: error)
                self.operation.completeOperation()

            })

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
