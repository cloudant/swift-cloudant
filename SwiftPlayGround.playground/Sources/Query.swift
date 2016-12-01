import Foundation
import SwiftCloudant

public extension Database {
    

    
    /// Creates a JSON query index.
    ///
    /// - Parameter fields: The fields to index.
    /// - Returns: The http information reccived from the server
    /// - Throws: If an error occured creating the index.
    public func createIndex(fields: [Sort]) throws -> HTTPInfo {
        var http: HTTPInfo?
        var error: Swift.Error?
        
        let index = CreateJSONQueryIndexOperation(databaseName: self.name, fields: fields) { _, info, opError in
            http = info
            error = opError
        }
        client.add(operation: index).waitUntilFinished()
        
        if let http = http, error == nil{
            return (http)
        } else if let error = error {
            throw error
        } else {
            throw Database.Error.unknown
        }
    }
    
    
    /// Finds documents in the database which match the provided selector.
    ///
    /// - Parameter selector: The selector to use when matching documents
    /// - Returns: A tuple of `docs` the documents found (relates to the
    /// - Throws: If error occured performing the query on the server.
    public func find(selector: [String:Any]) throws -> (docs: [[String:Any]], respone:[String:Any], httpInfo: HTTPInfo){
        
        
        var result: [String:Any]?
        var http: HTTPInfo?
        var error: Swift.Error?
        
        let find = FindDocumentsOperation(selector: selector, databaseName: self.name){ response, info, opError in
            result = response
            http = info
            error = opError
        }
        client.add(operation: find).waitUntilFinished()
        if let result = result, let http = http, error == nil {
            let docs = result["docs"] as! [[String:Any]]
            return (docs, result, http)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
        
    }
    
}
