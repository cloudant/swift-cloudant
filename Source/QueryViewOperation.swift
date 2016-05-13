//
//  QueryViewOperation.swift
//  SwiftCloudant
//
//
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

 An operation to query a view.

 - Requires: the `designDoc` and `viewName` properties must be set on this operation.

 Example usage:
 ```
 let view = QueryViewOperation()
 view.dbName = "example"
 view.designDoc = "exampleDesignDoc"
 view.viewName = "exampleView"

 // Set a row handler to process each returned row
 view.rowHandler = {(row) in
    // Do something with row JSON
    // Example: get the value
    row["value"]
 }

 // Set a completion handler to get a callback
 // when the operation finishes
 view.completionHandler = {(response, httpInfo, error) in
    if error != nil {
        // Example: handle an error by printing a message
        print("Error")
    }
 }

 // Add the operation to the database operation queue
 database.add(view)
 ```
 */
public class QueryViewOperation: CouchDatabaseOperation {

    /**
     The name of the design document which contains the view.

     - Note: must be set for a query view operation to successfully run.
     */
    public var designDoc: String? = nil

    /**
     The name of the view to query.

     - Note: must be set for a query view operation to successfully run.
     */
    public var viewName: String? = nil

    /**
     Return the result rows in 'descending by key' order.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var descending: Bool? = nil

    /**
     Return key/value result rows starting from the specified key.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var startKey: AnyObject? = nil

    /**
     Used in conjunction with startKey to further restrict the starting row for
     cases where two documents emit the same key. Specifying the doc ID allows
     the view to return result rows from the specified start key and document.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var startKeyDocId: String? = nil

    /**
     Stop the view returning result rows when the specified key is reached.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var endKey: AnyObject? = nil

    /**
     Used in conjunction with endKey to further restrict the ending row for cases
     where two documents emit the same key. Specifying the doc ID allows the view
     to return result rows up to the specified end key and document.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var endKeyDocId: String? = nil

    /**
     Include result rows with the specified `endKey`.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var inclusiveEnd: Bool? = nil

    /**
     Return only result rows that match the specified key.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.

     - Warning: Cannot be used with `keys` option.
     */
    public var key: AnyObject? = nil

    /**
     Return only result rows that match the specified keys.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.

     - Warning: Cannot be used with `key` option.
     */
    public var keys: Array<AnyObject>? = nil

    /**
     Limit the number of result rows returned from the view.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var limit: Int? = nil

    /**
     The number of rows to skip in the view results.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var skip: Int? = nil

    /**
     Include the full content of documents in the view results.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var includeDocs: Bool? = nil

    /**
     Use the reduce function for the view.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var reduce: Bool? = nil

    /**
     Group the results of a reduce based on their keys.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.

     - Warning: Only valid when a `reduce` function is used.
     */
    public var group: Bool? = nil

    /**
     Control view aggregation of complex keys by setting the number of elements of the key array to use for grouping reduce results.

     For example, if the view emits complex keys of the form `["A", "B", "C"]` and is using a `_count` reduce function then setting `groupLevel` would have these effects:
     * `view.groupLevel = 3` would produce rows of the form `{ "key" : ["A", "B", "C"], "value" : n }` where `n` is the count of documents with key `["A", "B", "C"]
     * `view.groupLevel = 1` would produces rows of the form `{ "key" : ["A"], "value" : m }` where `m` is the aggregated count of all keys with "A" as the first element

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.

     - Warning: Only valid if `group` is `true`
     */
    public var groupLevel: Int? = nil

    /**
     Acceptable values for allowing stale views with the `stale` property. To disallow stale views use the default `stale=nil`.
     */
    public enum Stale: CustomStringConvertible {
        /// Allow stale views.
        case Ok
        /// Allow stale views, but update them immediately after the request.
        case UpdateAfter

        public var description: String {
            switch self {
            case .Ok: return "ok"
            case .UpdateAfter: return "update_after"
            }
        }
    }

    /**
     Configures the view request to allow the return of stale results, that is allowing the view to return immediately rather than waiting for the view index to build. When this parameter is omitted (i.e. with the default of `stale=nil`) the server will not return stale results.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     - SeeAlso: `Stale` for descriptions of the available values for allowing stale views.
     - Warning: This is an advanced option, it should not be used unless you fully understand the outcome of changing the value of this property.
     */
    public var stale: Stale? = nil

    /**
     Sets a handler to run for each row retrieved by the view.

     - parameter row: dictionary of the JSON data from the view row
     */
    public var rowHandler: ((row: [String: AnyObject]) -> Void)?

    public override func validate() -> Bool {
        // Design doc and view name must be set
        if designDoc == nil || viewName == nil {
            return false
        }
        // Only one of key or keys can be used
        if key != nil && keys != nil {
            return false
        }
        if reduce != nil && !reduce! {
            // reduce=false, check that group and groupLevel are not used
            if group != nil || groupLevel != nil {
                return false
            }
        } else {
            // reduce=true, check that group level is not specified without group
            if !(group != nil && group!) && groupLevel != nil {
                return false
            }
        }
        return super.validate()
    }

    public override var httpMethod: String {
        if (keys != nil) {
            return "POST"
        } else {
            return "GET"
        }
    }

    public override var httpRequestBody: NSData? {
        if let keys = keys {
            do {
                let keysDict: NSDictionary = ["keys": keys as NSArray]
                let keysJson = try NSJSONSerialization.data(withJSONObject: keysDict)
                return keysJson
            } catch {
                callCompletionHandler(error: error)
            }
        }
        return nil
    }

    public override var httpPath: String {
        return "/\(self.databaseName!)/_design/\(designDoc!)/_view/\(viewName!)"
    }

    public override var queryItems: [NSURLQueryItem] {
        get {
            var items: [NSURLQueryItem] = []

            if let descending = descending {
                items.append(NSURLQueryItem(name: "descending", value: "\(descending)"))
            }

            if let startKeyJson = startKeyJson {
                items.append(NSURLQueryItem(name: "startkey", value: startKeyJson))
            }

            if let startKeyDocId = startKeyDocId {
                items.append(NSURLQueryItem(name: "startkey_docid", value: "\(startKeyDocId)"))
            }

            if let endKeyJson = endKeyJson {
                items.append(NSURLQueryItem(name: "endkey", value: endKeyJson))
            }

            if let endKeyDocId = endKeyDocId {
                items.append(NSURLQueryItem(name: "endkey_docid", value: "\(endKeyDocId)"))
            }

            if let inclusiveEnd = inclusiveEnd {
                items.append(NSURLQueryItem(name: "inclusive_end", value: "\(inclusiveEnd)"))
            }

            if let keyJson = keyJson {
                items.append(NSURLQueryItem(name: "key", value: keyJson))
            }

            if let limit = limit {
                items.append(NSURLQueryItem(name: "limit", value: "\(limit)"))
            }

            if let skip = skip {
                items.append(NSURLQueryItem(name: "skip", value: "\(skip)"))
            }

            if let includeDocs = includeDocs {
                items.append(NSURLQueryItem(name: "include_docs", value: "\(includeDocs)"))
            }

            if let reduce = reduce {
                items.append(NSURLQueryItem(name: "reduce", value: "\(reduce)"))
            }

            if let group = group {
                items.append(NSURLQueryItem(name: "group", value: "\(group)"))
            }

            if let groupLevel = groupLevel {
                items.append(NSURLQueryItem(name: "group_level", value: "\(groupLevel)"))
            }

            if let stale = stale {
                items.append(NSURLQueryItem(name: "stale", value: "\(stale)"))
            }

            return items
        }
    }

    private var keyJson: String?
    private var endKeyJson: String?
    private var startKeyJson: String?

    public override func serialise() throws {
        if let key = key {
            keyJson = try convertJson(key: key)
        }
        if let endKey = endKey {
            endKeyJson = try convertJson(key: endKey)
        }

        if let startKey = startKey {
            startKeyJson = try convertJson(key: startKey)
        }

    }

    public override func processResponse(json: [String: AnyObject]) {
        let rows = json["rows"] as! [[String: AnyObject]]
        for row: [String: AnyObject] in rows {
            self.rowHandler?(row: row)
        }
    }

    func convertJson(key: AnyObject) throws -> String {
        if NSJSONSerialization.isValidJSONObject(key) {
            let keyJson = try NSJSONSerialization.data(withJSONObject: key)
            return String(data: keyJson, encoding: NSUTF8StringEncoding)!
        } else if key is String {
            // we need to quote JSON primitive strings
            return "\"\(key)\""
        } else {
            // anything else we just try as stringified JSON value
            return "\(key)"
        }
    }
}
