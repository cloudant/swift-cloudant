//
//  FindDocumentsOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 20/04/2016.
//  Copyright (c) 2016 IBM Corp.
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
 Specfies how a field should be sorted
 */
public struct Sort {
    
    /**
     The direction of Sorting
     */
    public enum Direction: String {
        /**
         Sort ascending
         */
        case asc = "asc"
        /**
         Sort descending
         */
        case desc = "desc"
    }

    /**
     The field on which to sort
     */
    public let field: String
    
    /**
     The direction in which to sort.
     */
    public let sort: Direction?
  
    public init(field: String, sort: Direction?) {
        self.field = field
        self.sort = sort
    }
}

/**
 Protocol for operations which deal with the Mango API set for CouchDB / Cloudant.
*/
internal protocol MangoOperation {
    
}

internal extension MangoOperation {
    /**
        Transform an Array of Sort into a Array in the form of Sort Syntax.
    */
    internal func transform(sortArray: [Sort]) -> [Any] {
        
        var transformed: [Any] = []
        for s in sortArray {
            if let sort = s.sort {
                let dict = [s.field: sort.rawValue]
                transformed.append(dict)
            } else {
                    transformed.append(s.field)
            }
        }
        
        return transformed
    }

    /**
        Transform an array of TextIndexField into an Array in the form of Lucene field definitions.
    */
    internal func transform(fields: [TextIndexField]) -> [[String:String]] {
        var array: [[String:String]] = []

        for field in fields {
            array.append([field.name: field.type.rawValue])
        }

        return array
    }
}

/**
 Usage example:

 ```
 let find = FindDocumentsOperation(selector:["foo":"bar"], databaseName: "exampledb", fields: ["foo"], sort: [Sort(field: "foo", sort: .Desc)], documentFoundHandler: { (document) in
    // Do something with the document.
 }) {(response, httpInfo, error) in
    if let error = error {
        // handle the error.
    } else {
        // do something on success.
    }
 }
 client.add(operation:find)
 
 ```
 */
public class FindDocumentsOperation: CouchDatabaseOperation, MangoOperation, JSONOperation {
    
    /**
    
     Creates the operation.
     
     - parameter selector: the selector to use to select documents in the database.
     - parameter databaseName: the name of the database the find operation should be performed on.
     - parameter fields: the fields of a matching document which should be returned in the repsonse.
     - parameter limit: the maximium number of documents to be returned.
     - parameter skip: the number of matching documents to skip before returning matching documents.
     - parameter sort: how to sort the match documents
     - parameter bookmark: A bookmark from a previous index query, this is only valid for text indexes.
     - parameter useIndex: Which index to use when matching documents
     - parameter r: The read quorum for this request.
     - parameter documentFoundHandler: a handler to call for each document in the response.
     - parameter completionHandler: optional handler to call when the operations completes.
    
     
     - warning: `r` is an advanced option and is rarely, if ever, needed. It **will** be detrimental to
     performance.
     
     - remark: The `bookmark` option is only valid for text indexes, a `bookmark` is returned from 
     the server and can be accessed in the completionHandler with the following line: 
     
     ````
     let bookmark = response["bookmark"]
     ````
     
     - seealso: [Query sort syntax](https://docs.cloudant.com/cloudant_query.html#sort-syntax)
     - seealso: [Selector syntax](https://docs.cloudant.com/cloudant_query.html#selector-syntax)
    
     */
    public init(selector: [String: Any],
            databaseName: String,
                  fields: [String]? = nil,
                   limit: UInt? = nil,
                    skip: UInt? = nil,
                    sort: [Sort]? = nil,
                bookmark: String? = nil,
                useIndex:String? = nil,
                       r: UInt? = nil,
    documentFoundHandler: (([String: Any]) -> Void)? = nil,
       completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.selector = selector
        self.databaseName = databaseName
        self.fields = fields
        self.limit = limit
        self.skip = skip
        self.sort = sort
        self.bookmark = bookmark
        self.useIndex = useIndex;
        self.r = r
        self.documentFoundHandler = documentFoundHandler
        self.completionHandler = completionHandler
    }
    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    public let databaseName: String
    
    /**
     The selector for the query, as a dictionary representation. See
     [the Cloudant documentation](https://docs.cloudant.com/cloudant_query.html#selector-syntax)
     for syntax information.
     */
    public let selector: [String: Any]?;

    /**
     The fields to include in the results.
     */
    public let fields: [String]?

    /**
     The number maximium number of documents to return.
     */
    public let limit: UInt?

    /**
     Skip the first _n_ results, where _n_ is specified by skip.
     */
    public let skip: UInt?

    /**
     An array that indicates how to sort the results.
     */
    public let sort: [Sort]?

    /**
     A string that enables you to specify which page of results you require.
     */
    public let bookmark: String?

    /**
     A specific index to run the query against.
     */
    public let useIndex: String?

    /**
     The read quorum for this request.
     */
    public let r: UInt?

    /**
     Handler to run for each document retrived from the database matching the query.

     - parameter document: a document matching the query.
     */
    public let documentFoundHandler: (([String: Any]) -> Void)?

    private var json: [String: Any]?

    public var method: String {
        return "POST"
    }

    public var endpoint: String {
        return "/\(self.databaseName)/_find"
    }

    private var jsonData: Data?
    public var data: Data? {
        return self.jsonData
    }

    public func validate() -> Bool {
        let jsonObj = createJsonDict()
        if JSONSerialization.isValidJSONObject(jsonObj) {
            self.json = jsonObj
            return true
        } else {
            return false;
        }

    }
    
    private func createJsonDict() -> [String: Any] {
        // build the body dict, we will store this to save compute cycles.
        var jsonObj: [String: Any] = [:]
        if let selector = self.selector {
            jsonObj["selector"] = selector
        }
        
        if let limit = self.limit {
            jsonObj["limit"] = limit
        }
        
        if let skip = self.skip {
            jsonObj["skip"] = skip
        }
        
        if let r = self.r {
            jsonObj["r"] = r
        }
        
        if let sort = self.sort {
            jsonObj["sort"] = transform(sortArray: sort)
        }
        
        if let fields = self.fields {
            jsonObj["fields"] = fields
        }
        
        if let bookmark = self.bookmark {
            jsonObj["bookmark"] = bookmark
        }
        
        if let useIndex = self.useIndex {
            jsonObj["use_index"] = useIndex
        }
        
        return jsonObj
    }

    internal class func transform(sortArray: [Sort]) -> [Any] {

        var transfomed: [Any] = []
        for s in sortArray {
            if let sort = s.sort {
                let dict = [s.field: sort.rawValue]
                transfomed.append(dict)
            } else {
                transfomed.append(s.field)
            }
        }

        return transfomed
    }

    public func serialise() throws {
        
        if self.json == nil {
            self.json = createJsonDict()
        }
 
        if let json = self.json {
            self.jsonData = try JSONSerialization.data(withJSONObject: json)
        }
    }

    public func processResponse(json: Any) {
        if let json = json as? [String: Any],
           let docs = json["docs"] as? [[String: Any]] { // Array of [String:Any]
            for doc: [String: Any] in docs {
                self.documentFoundHandler?(doc)
            }
        }
    }
    
    public func callCompletionHandler(response: Any?, httpInfo: HTTPInfo?, error: Error?) {
        self.completionHandler?(response as? [String: Any], httpInfo, error)
    }


}
