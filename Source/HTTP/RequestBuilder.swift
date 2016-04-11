//
//  RequestBuilder.swift
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


// TODO rename to something that makes a little more swift sense.
protocol HTTPRequestOperation {
    
    var session:InterceptableSession { get }
    
    var rootURL:NSURL { get}
    
    var httpPath:String { get }
    
    var httpMethod : String { get }
    
    var queryItems:[NSURLQueryItem] { get }
    
    //return nil if there is no body
    var httpRequestBody:NSData? { get }
    
    
    func completeOpetation()
    
    func processResponse(data:NSData?, statusCode:Int, error:ErrorType?);
    
    var cancelled: Bool { get }
    
}


class OperationRequestBuilder {
    
    
    let operation:HTTPRequestOperation
    
    init(operation:HTTPRequestOperation){
        self.operation = operation
    }
    
    
    func buildRequest() -> NSURLRequest {
        guard let components = NSURLComponents(URL: operation.rootURL, resolvingAgainstBaseURL: false)
        else {
            //crash for now
            abort()
        }
        components.path = operation.httpPath
        var queryItems : [NSURLQueryItem] = []
        
        if let _ = components.queryItems {
            queryItems.appendContentsOf(components.queryItems!)
        }
        
        queryItems.appendContentsOf(operation.queryItems)
        components.queryItems = queryItems
        
        guard let url = components.URL
        else {
            // crash for now
            abort()
        }
        let request = NSMutableURLRequest(URL: url)
        request.cachePolicy = .UseProtocolCachePolicy
        request.timeoutInterval = 10.0
        request.HTTPMethod = operation.httpMethod
        
        if let body = operation.httpRequestBody {
            request.HTTPBody = body
        }
        
        
        return request

    }
    
}




































