//
//  RequestBuilder.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
//  Copyright © 2016 Small Text. All rights reserved.
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




































