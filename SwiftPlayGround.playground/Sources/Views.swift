import Foundation
import SwiftCloudant


public extension Database {
    
    
    /// Query a view.
    ///
    /// - Parameters:
    ///   - name: The name of the view to query
    ///   - designDocumentID: The id of the design document to use
    /// - Returns: A tuple of:
    ///      - `rows` the rows of the view, this is a pre casted result of `response["rows"]`
    ///      - `response` the full JSON response from the server
    ///      - `http` the http information recieved from the  server.
    /// - Throws:
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
