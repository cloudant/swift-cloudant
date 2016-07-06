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
 view.databaseName = "exampledb"

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
 client.add(view)
 ```
 */
public class QueryViewOperation: ViewOperation, JsonOperation {
    
    public init() { }
    
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: ErrorProtocol?) -> Void)?
    public var databaseName: String?

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
    public var limit: UInt? = nil

    /**
     The number of rows to skip in the view results.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var skip: UInt? = nil

    /**
     Include the full content of documents in the view results.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    public var includeDocs: Bool? = nil
    
    public var conflicts: Bool? = nil

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
     Configures the view request to allow the return of stale results, that is allowing the view to return immediately rather than waiting for the view index to build. When this parameter is omitted (i.e. with the default of `stale=nil`) the server will not return stale results.

     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     - SeeAlso: `Stale` for descriptions of the available values for allowing stale views.
     - Warning: This is an advanced option, it should not be used unless you fully understand the outcome of changing the value of this property.
     */
    public var stale: Stale? = nil
    
    public var updateSeq: Bool?

    /**
     Sets a handler to run for each row retrieved by the view.

     - parameter row: dictionary of the JSON data from the view row
     */
    public var rowHandler: ((row: [String: AnyObject]) -> Void)?

    public func validate() -> Bool {
        
        if databaseName == nil {
            return false
        }
        
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
        return true
    }

    public var data: Data? {
        if let keys = keys {
            do {
                #if os(Linux)
                    let keysDict: NSDictionary = ["keys".bridge() : keys.bridge()]
                #else
                    let keysDict: NSDictionary = ["keys": keys as NSArray]
                #endif
                let keysJson = try JSONSerialization.data(withJSONObject: keysDict)
                return keysJson
            } catch {
                callCompletionHandler(error: error)
            }
        }
        return nil
    }

    public var endpoint: String {
        return "/\(self.databaseName!)/_design/\(designDoc!)/_view/\(viewName!)"
    }

    public var parameters: [String: String] {
        get {
            var items: [String: String] = generateParams()

            // Add parameters not handled by the protocol.
            if let startKeyJson = startKeyJson {
                items["startkey"] = startKeyJson
            }

            if let endKeyJson = endKeyJson {
                items["endkey"] =  endKeyJson
            }

            if let keyJson = keyJson {
                items["key"] = keyJson
            }

            if let reduce = reduce {
                items["reduce"] = "\(reduce)"
            }

            if let group = group {
                items["group"] = "\(group)"
            }

            if let groupLevel = groupLevel {
                items["group_level"] = "\(groupLevel)"
            }

            return items
        }
    }

    private var keyJson: String?
    private var endKeyJson: String?
    private var startKeyJson: String?

    public  func serialise() throws {
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

}
