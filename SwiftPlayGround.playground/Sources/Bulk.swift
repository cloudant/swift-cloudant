import Foundation
import SwiftCloudant



public extension Database {
    
    public func allDocuments() throws -> (docs:[[String:Any]], response: [String:Any], http: HTTPInfo) {
        var response: [String:Any]?
        var http: HTTPInfo?
        var error: Swift.Error?
        
        let all = GetAllDocsOperation(databaseName: self.name) { opResponse, info, opError in
            response = opResponse
            http = info
            error = opError
        }
        
        client.add(operation: all).waitUntilFinished()
        if let response = response, let http = http, error == nil, let docs = response["rows"] as? [[String:Any]] {
            return (docs, response, http)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
    }
    
    public func allDocuments(handler: @escaping (([String:Any]) -> Void)) throws {
        var error: Swift.Error?
        
        let all = GetAllDocsOperation(databaseName: self.name,rowHandler:handler) { _, _, opError in
            error = opError
        }
        client.add(operation: all).waitUntilFinished()
        
        if let error = error {
            throw error
        }
        
    }
    
}
