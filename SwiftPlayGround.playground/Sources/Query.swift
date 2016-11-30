import Foundation
import SwiftCloudant

public extension Database {
    
    
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
