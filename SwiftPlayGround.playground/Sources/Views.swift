import Foundation
import SwiftCloudant


public extension Database {
    public func queryView(name: String, designDocumentID:String) throws -> (rows:[[String:Any]], response:[String:Any], http: HTTPInfo) {
        var result: [String:Any]?
        var http:HTTPInfo?
        var error: Swift.Error?
        
        let view = QueryViewOperation(name: name, designDocumentID: designDocumentID , databaseName: self.name){ response, info, opError in
            result = response
            http = info
            error = opError
        }
        client.add(operation: view).waitUntilFinished()
        if let result = result, let http = http, error == nil {
            let rows = result["rows"] as! [[String:Any]]
            return (rows, result, http)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
        
    }
}
