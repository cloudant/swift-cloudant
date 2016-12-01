import Foundation
import SwiftCloudant



public extension Database {
    
    
    /// Gets all the documents from the database
    ///
    /// - Returns: A tuple of the documents returned, the deseralised json response, http info.
    /// - Throws: An error there was a problem fetching the documents from the server.
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
    
    
    /// Gets all documents and invokes the provided handler for each document in the database.
    ///
    /// - Remark: This method is synchronous and the closure will run for each document before
    ///    the method returns however the clousre **will** be called on a different thread 
    ///    to the thread that called this method/
    ///
    /// - Parameter handler: A closure to invoke for each document
    /// - Throws: An Error if there was a problem fetching the documents from the server.
    public func allDocuments(handler: @escaping (([String:Any]) -> Void)) throws {
        var error: Swift.Error?
        
        let all = GetAllDocsOperation(databaseName: self.name,rowHandler: handler) { _, _, opError in
            error = opError
        }
        client.add(operation: all).waitUntilFinished()
        
        if let error = error {
            throw error
        }
        
    }
    
}
