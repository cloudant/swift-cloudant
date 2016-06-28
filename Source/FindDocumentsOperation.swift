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
 The direction of Sorting
 */
public enum SortDirection: String {
    /**
     Sort ascending
     */
    case Asc = "asc"
    /**
     Sort descending
     */
    case Desc = "desc"
}

/**
 Specfies how a field should be sorted
 */
public struct Sort {

    /**
     The field on which to sort
     */
    let field: String
    let sort: SortDirection?
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
    internal func transform(sortArray: [Sort]) -> [AnyObject] {
        
        var transformed: [AnyObject] = []
        for s in sortArray {
            if let sort = s.sort {
                let dict = [s.field: sort.rawValue]
                transformed.append(dict as NSDictionary)
            } else {
                transformed.append(s.field as NSString)
            }
        }
        
        return transformed
    }

    /**
        Transform an array of TextIndexField into an Array in the form of Lucene field definitions.
    */
    internal func transform(fields: [TextIndexField]) -> NSArray {
        var array: [[String:String]] = []

        for field in fields {
            array.append([field.name: field.type.rawValue])
        }

        return array as NSArray
    }
}

/**
 Usage example:

 ```
 let find = FindDocumentsOperation()
 find.selector = ["foo":"bar"]
 find.fields = ["foo"]
 find.sort = [Sort(field: "foo", sort: .Desc)]
 find.databaseName = "exampledb"
 find.documentFoundHanlder = { (document) in
    // Do something with the document.
 }
 find.completionHandler = {(response, httpInfo, error) in
    if let error = error {
        // handle the error.
    } else {
        // do something on success.
    }
 }
 client.add(operation:find)
 
 ```
 */
public class FindDocumentsOperation: CouchDatabaseOperation, MangoOperation, JsonOperation {
    
    public init() { }
    
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: ErrorProtocol?) -> Void)?
    public var databaseName: String?
    
    /**
     The selector for the query, as a dictionary representation. See
     [the Cloudant documentation](https://docs.cloudant.com/cloudant_query.html#selector-syntax)
     for syntax information.

     Required: This needs to be set before the operation can successfully run.
     */
    public var selector: [String: AnyObject]?;

    /**
     The fields to include in the results.

     - Note: Optional: if the property is unset this parameter will
     not be included in the request and the server default will apply.
     */
    public var fields: [String]?

    /**
     The number maximium number of documents to return.

     - Note: Optional, if the property is unset this parameter will
      not be included in the request and the server default will apply.
     */
    public var limit: Int?

    /**
     Skip the first _n_ results, where _n_ is specified by skip.

     - Note: Optional, if the property is unset this parameter will not be
     included in the request and the server default will apply.
     */
    public var skip: Int?

    /**
     An array that indicates how to sort the results.
     
     - SeeAlso: [Query sort syntax](https://docs.cloudant.com/cloudant_query.html#sort-syntax)

     - Note: Optional, if the property is unset this parameter will not be included
     in the request and the server default will apply.
     */
    public var sort: [Sort]?

    /**
     A string that enables you to specify which page of results you require.

     - Note: Optional, if the property is unset this parameter will not be included
     in the request and the server default will apply.

     - Remark: This is only valid for text indexes.
     */
    public var bookmark: String?

    /**
     A specific index to run the query against.

     - Note: Optional, if the property is unset this parameter will not be
     included in the request and the server default will apply.
     */
    public var useIndex: String?

    /**
     The read quorum for this request.

     - Note: Optional, if the property is unset this parameter will not be included
     in the request and the server default will apply.

     - warning: This is an advanced option and is rarely, if ever, needed. It will be detrimental to
     performance.

     */
    public var r: Int?

    /**
     Handler to run for each document retrived from the database matching the query.

     - parameter document: a document matching the query.
     */
    public var documentFoundHandler: ((document: [String: AnyObject]) -> Void)?

    private var json: [String: AnyObject]?

    public var method: String {
        return "POST"
    }

    public var endpoint: String {
        return "/\(self.databaseName!)/_find"
    }

    private var jsonData: NSData?
    public var data: NSData? {
        return self.jsonData
    }

    public func validate() -> Bool {
        if databaseName == nil  {
            return false
        }
        
        if self.selector == nil {
            return false
        }

        let jsonObj = createJsonDict()
        if NSJSONSerialization.isValidJSONObject(jsonObj as NSDictionary) {
            self.json = jsonObj
            return true
        } else {
            return false;
        }
    }
    
    private func createJsonDict() -> [String: AnyObject] {
        // build the body dict, we will store this to save compute cycles.
        var jsonObj: [String: AnyObject] = [:]
        
        if let selector = self.selector {
            jsonObj["selector"] = selector as NSDictionary
        }
        
        if let limit = self.limit {
            jsonObj["limit"] = limit as NSNumber
        }
        
        if let skip = self.skip {
            jsonObj["skip"] = skip as NSNumber
        }
        
        if let r = self.r {
            jsonObj["r"] = r as NSNumber
        }
        
        if let sort = self.sort {
            jsonObj["sort"] = transform(sortArray: sort) as NSArray
        }
        
        if let fields = self.fields {
            jsonObj["fields"] = fields as NSArray
        }
        
        if let bookmark = self.bookmark {
            jsonObj["bookmark"] = bookmark as NSString
        }
        
        if let useIndex = self.useIndex {
            jsonObj["use_index"] = useIndex as NSString
        }

        return jsonObj
    }

    internal class func transform(sortArray: [Sort]) -> [AnyObject] {

        var transfomed: [AnyObject] = []
        for s in sortArray {
            if let sort = s.sort {
                let dict = [s.field: sort.rawValue]
                transfomed.append(dict as NSDictionary)
            } else {
                transfomed.append(s.field as NSString)
            }
        }

        return transfomed
    }

    public func serialise() throws {
        
        if self.json == nil {
            self.json = createJsonDict()
        }
 
        if let json = self.json {
            self.jsonData = try NSJSONSerialization.data(withJSONObject: json as NSDictionary)
        }
    }

    public func processResponse(json: Any) {
        if let json = json as? [String: AnyObject],
           let docs = json["docs"] as? [[String: AnyObject]] { // Array of [String:AnyObject]
            for doc: [String: AnyObject] in docs {
                self.documentFoundHandler?(document: doc)
            }
        }
    }
    
    public func callCompletionHandler(response: Any?, httpInfo: HTTPInfo?, error: ErrorProtocol?) {
        self.completionHandler?(response: response as? [String: AnyObject], httpInfo: httpInfo, error: error)
    }


}
