import Foundation
import SwiftCloudant


public struct Response {
    public let httpInfo: HTTPInfo
    public let id: String
    public let rev: String
}



public struct Database {
    
    let name: String
    let client: CouchDBClient
    
    public init(name:String, client:CouchDBClient){
        self.name = name
        self.client = client
    }
    
    
    public enum Error : Swift.Error {
        case unknown
    }
    
    public func create() throws -> HTTPInfo {
        var http: HTTPInfo?
        var error: Swift.Error?
        let create = CreateDatabaseOperation(name: self.name){ _, info, opError in
            http = info
            error = opError
        }
        self.client.add(operation: create).waitUntilFinished()
        if let httpInfo = http, error == nil {
            return httpInfo
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
    }
    
    // hmmm perhaps document should become id or soething like that.
    public func get(document: String) throws -> (response:[String: Any],httpInfo: HTTPInfo) {
        var document: [String:Any]? = nil
        var error: Swift.Error? = nil
        var httpInfo: HTTPInfo? = nil
        let get = GetDocumentOperation(id: "test", databaseName: "test"){ response, http, httpError in
            document = response
            error = httpError
            httpInfo = http
            
        }
        client.add(operation: get).waitUntilFinished()
        if let document = document, let httpInfo = httpInfo, error == nil {
            return (document, httpInfo)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
    }
    
    public func save(document: [String:Any]) throws -> (response: [String:Any], httpInfo: HTTPInfo){
        var saved: [String: Any]?
        var httpInfo: HTTPInfo?
        var error: Swift.Error?
        
        
        let id: String? = document["_id"] as? String
        let put = PutDocumentOperation(id: id, body: document, databaseName: self.name){ response, http, opError in
            saved = response
            httpInfo = http
            error = opError
            
        }
        client.add(operation: put).waitUntilFinished()

        if let saved = saved, let httpInfo = httpInfo, error == nil {
            return (saved, httpInfo)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
        
    }
    
    public func bulk(documents: [[String:Any]]) throws -> (response: [[String:Any]],httpInfo: HTTPInfo) {
        var result: [[String:Any]]?
        var http: HTTPInfo?
        var error: Swift.Error?
        
        let bulk = PutBulkDocsOperation(databaseName: self.name, documents: documents){ response, info, opError in
            result = response
            http = info
            error = opError
        }
        client.add(operation: bulk).waitUntilFinished()
        
        if let result = result, let http = http, error == nil {
            return (result, http)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
    }
    
    public func delete(document:String, revision: String) throws -> (respone: [String:Any], httpInfo: HTTPInfo) {
        var result: [String:Any]?
        var http: HTTPInfo?
        var error: Swift.Error?
        
        let delete = DeleteDocumentOperation(id: document, revision: revision, databaseName: self.name){ response, info, opError in
            result = response
            http = info
            error = opError
        }
        client.add(operation: delete).waitUntilFinished()
        
        if let result = result, let http = http, error == nil {
            return (result, http)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
    }
    

    
    public func delete() throws -> (respone: [String:Any], httpInfo: HTTPInfo) {
        var response: [String:Any]?
        var http: HTTPInfo?
        var error: Swift.Error?
        let delete = DeleteDatabaseOperation(name: self.name){ opResponse, info, opError in
            response = opResponse
            http = info
            error = opError
        }
        self.client.add(operation: delete).waitUntilFinished()
        if let result = response, let http = http, error == nil {
            return (result, http)
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
    }
}

public extension CouchDBClient {
    
    convenience init(account: String, username: String, password:String, configuration: ClientConfiguration = ClientConfiguration(shouldBackOff: false)) {
        self.init(url: URL(string:"https://\(account).cloudant.com")!, username: username, password: password, configuration: configuration)
    }
    
    func database(_ name:String) -> Database {
        return Database(name: name, client:self)
    }
}

