//
//  GetChangesOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 22/08/2016.
//
//  Copyright (C) 2016 IBM Corp.
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

/**
 Operation to get the changes feed for a database.
 
 Example usage:
 ```
 let changes = GetChangesOperation(dbName: "exampleDB", changeHandler: {(change) in 
    // do something for each change.
 }) { (response, info, error) in 
    if let error = error {
        // handle the error
    } else {
        // process the changes feed result.
    }
 }
 ```
 */
public class GetChangesOperation : CouchDatabaseOperation, JSONOperation {
    
    public typealias Json = [String: Any]

    /**
     Abstract representation of a CouchDB Sequence. No assumptions should be
     made about the concrete type that is returned from the server, it should be used
     transparently.
     */
    public typealias Sequence = Any
    
    /**
     The style of changes feed that should be requested.
     */
    public enum Style : String {
        /**
         Only the "winning" revision.
         */
        case main = "main_only"
        /**
         All "leaf" revisions (include previously deleted conflicts).
         */
        case allLeaves = "all_docs"
    }
    
    public let databaseName: String
    
    public let completionHandler: (([String: Any]?, HTTPInfo?, Error?) -> Void)?
    
    /**
     List of document IDs to limit the changes to.
     */
    public let docIDs: [String]?
    
    /**
     Include conflict information in the response.
     */
    public let conflicts: Bool?
    
    /**
     Sort the changes feed in descending sequence order.
     */
    public let descending: Bool?
    
    /**
      The filter function to use to filter the feed.
     */
    public let filter: String?
    
    /**
     Include the associated document with each result in the changes feed.
     */
    public let includeDocs: Bool?
    
    /**
     Include attachments as Base-64 encoded data in the document.
     */
    public let includeAttachments: Bool?
    
    /**
     Include information encoding in attachment stubs.
     */
    public let includeAttachmentEncodingInformation: Bool?
    
    /**
     The number of results that the feed should be limited to.
     */
    public let limit: Int?
    
    /**
     Return results starting from the sequence after.
     */
    public let since: Sequence?
    
    /**
     Specifies how many revisions are returned in the changes array.
     */
    public let style: Style?
    
    /**
     The view to use for filtering the changes feed, to be used with the `_view` filter.
     */
    public let view: String?
    
    /**
     A handler to run for each entry in the `results` array in the response.
     */
    public let changeHandler: (([String: Any]) -> Void)? // this will be each result in the `results` section of the response
    
    /**
     Creates the operation.
     
     - param databaseName: The name of the database from which to get the changes
     - param docIDs: Document IDs to limit the changes result to.
     - param conflicts: include information about conflicts in the response
     - param descending: sort the changes feed in descending sequence order.
     - param filter: the name of a filter function to use to filter the changes feed.
     - param includeDocs: include the document contents with the changes feed result.
     - param includeAttachments: include the attachments inline with the document results
     - param includeAttachmentEncodingInformation: Include attachment encoding information for attachment stubs
     - param limit: the number of results the response should be limited to.
     - param since: Return results starting from the sequence after this one.
     - param style: the style of changes feed that should be returned
     - param view: The view to use for filtering the changes feed, should be used with `_view` filter.
     - param changeHandler: A handler to call for each change returned from the server.
     - param completionHander: A handler to call when the operation has compeleted.
     */
    public init(databaseName:String,
                docIDs:[String]? = nil,
                conflicts: Bool? = nil,
                descending: Bool? = nil,
                filter: String? = nil,
                includeDocs: Bool? = nil,
                includeAttachments: Bool? = nil,
                includeAttachmentEncodingInformation: Bool? = nil,
                limit: Int? = nil,
                since: Int? = nil,
                style: Style? = nil,
                view: String? = nil,
                changeHandler: (([String: Any]) -> Void)? = nil,
                completionHandler: (([String: Any]?, HTTPInfo?, Error?) -> Void)? = nil){
        self.databaseName = databaseName
        self.docIDs = docIDs
        self.conflicts = conflicts
        self.descending = descending
        self.filter = filter
        self.includeDocs = includeDocs
        self.includeAttachments = includeAttachments
        self.includeAttachmentEncodingInformation = includeAttachmentEncodingInformation
        self.limit = limit
        self.since = since
        self.style = style
        self.view = view
        self.changeHandler = changeHandler
        self.completionHandler = completionHandler
    }
    
    public var endpoint: String {
        return "/\(self.databaseName)/_changes"
    }
    
    public var parameters: [String : String] {
        get {
            var params: [String: String] = [:]
            
            if let conflicts = conflicts {
                params["conflicts"] = conflicts.description
            }
            
            if let descending = descending {
                params["descending"] = descending.description
            }
            
            
            if let filter = filter {
                params["filter"] = filter
            }
            
            if let includeDocs = includeDocs {
                params["include_docs"] = includeDocs.description
            }
            
            if let includeAttachments = includeAttachments {
                params["attachments"] = includeAttachments.description
            }
            
            if let includeAttachmentEncodingInformation = includeAttachmentEncodingInformation {
                params["att_encoding_info"] = includeAttachmentEncodingInformation.description
            }
            
            if let limit = limit {
                params["limit"] = "\(limit)"
            }
            
            if let since = since {
                params["since"] = "\(since)"
            }
            
            if let style = style {
                params["style"] = style.rawValue
            }
            
            if let view = view {
                params["view"] = view
            }
            
            return params
        }
    }
    
    private var jsonData: Data? = nil
    
    public func serialise() throws {
        if let docIDs = docIDs {
            jsonData = try JSONSerialization.data(withJSONObject: ["doc_ids": docIDs])
        }
    }
    
    public var data: Data? {
        return jsonData
    }
    
    public func processResponse(json: Any) {
        if let json = json as? [String: Any],
            let results = json["results"] as? [[String: Any]] {
            for result in results {
                self.changeHandler?(result)
            }
        }
    }
    
    public var method: String {
        get {
            if let _ = jsonData {
                return "POST"
            } else {
                return "GET"
            }
        }
    }
    
}
