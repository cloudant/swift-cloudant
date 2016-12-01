import Foundation
import SwiftCloudant


public struct Database {
    
    
    /// The name of the database.
    let name: String
    
    /// The client to use when accessing the database.
    let client: CouchDBClient
    
    
    /// Creates a Database struct for the given name and client
    ///
    /// - Parameters:
    ///   - name: The name of the database
    ///   - client: The client to use when accessing the database.
    public init(name:String, client:CouchDBClient){
        self.name = name
        self.client = client
    }
    
    public enum Error : Swift.Error {
        case unknown
    }
    
    
    /// Creates the database on the server.
    ///
    /// - Returns: HTTP information reccived from the server.
    /// - Throws: If an error occured creating the database on the server.
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
    
    
    /// Get a document from the server
    ///
    /// - Parameter document: The ID of the document to get from the server.
    /// - Returns: the document and information about the HTTP response.
    /// - Throws: An error if an error occured getting the document from the server.
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
    
    
    /// Save a document to the server
    ///
    /// - Parameter document: The document to save
    /// - Returns: A tuple containing the response and the http information reccived from the server.
    /// - Throws: If an error occured saving the document.
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
    
    
    /// Upload documents in bulk to server
    ///
    /// - Parameter documents: Array of documents to upload to the server
    /// - Returns: A tuple of the response and http information recieved from the server
    /// - Throws: If an error occurs updating the documents.
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
    
    
    /// Deletes a document from the server
    ///
    /// - Parameters:
    ///   - document: The id of the document to delete
    ///   - revision: the revision of the document to delete
    /// - Returns: A tuple of the response and the http information reccieved from the server
    /// - Throws: If an error occurs deleting the document from the server.
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
    

    
    /// Delete the database from the server
    ///
    /// - Returns: The httpInfo reccived from the server.
    /// - Throws: If there was an error deleting the database from the server.
    public func delete() throws -> HTTPInfo {
        var http: HTTPInfo?
        var error: Swift.Error?
        let delete = DeleteDatabaseOperation(name: self.name){ _, info, opError in
            http = info
            error = opError
        }
        self.client.add(operation: delete).waitUntilFinished()
        if let http = http, error == nil {
            return http
        } else if let error = error {
            throw error
        } else {
            throw Error.unknown
        }
    }
}

public extension CouchDBClient {
    
    
    /// Create a `CouchDBClient` with a Cloudant account name.
    ///
    /// - Parameters:
    ///   - account: The account that the client should operate on.
    ///   - username: The user to authenticate with Cloudant as.
    ///   - password: The password to use when authenticating.
    ///   - configuration: The configuraton for the client, defaults to a do not back off configuration.
    convenience init(account: String, username: String, password:String, configuration: ClientConfiguration = ClientConfiguration(shouldBackOff: false)) {
        self.init(url: URL(string:"https://\(account).cloudant.com")!, username: username, password: password, configuration: configuration)
    }
    
    
    /// Creates a Database struct for the given name.
    ///
    /// - Parameter name: The name of the database
    /// - Returns: A Datavase struct for the given name.
    func database(_ name:String) -> Database {
        return Database(name: name, client:self)
    }
}

