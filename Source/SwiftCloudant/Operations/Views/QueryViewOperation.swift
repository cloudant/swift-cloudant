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
 let view = QueryViewOperation(name: "exampleView",
                     designDocument: "exampleDesignDoc",
                       databaseName: "exampledb")

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
public class QueryViewOperation: ViewOperation, JSONOperation {
    
    /**
     Creates the operation
     
     - parameter name: the name of the view to query
     - parameter designDocument: the ID of the design document which contains the view
     - parameter databaseName: the name of database where the design document is stored
     - parameter descending: Sort the results in descending order.
     - parameter startKey: The key from where to start returning results.
     - parameter startKeyDocumentID: Used in conjunction with startKey to further restrict the starting row for
     cases where two documents emit the same key. Specifying the doc ID allows
     the view to return result rows from the specified start key and document.
     - parameter endKey: Stop the view returning result rows when the specified key is reached.
     - parameter endKeyDocumentID: Used in conjunction with endKey to further restrict the ending row for cases
     where two documents emit the same key. Specifying the doc ID allows the view
     to return result rows up to the specified end key and document.
     - parameter inclusiveEnd: include the endKey in the returned result.
     - parameter key: return only rows matching the provided key
     - parameter keys: return only rows matching one of the provided keys.
     - parmeter limit: the number of rows the response should be limited to
     - parameter skip: the number of rows matching the query that should be skipped before returning results.
     - parameter includeDocs: Include the document body in the response.
     - parameter conflicts: Include information on documents which are in a conflicted state.
     - parameter reduce: Use the reduce function of the view.
     - parameter group: Group the results of a reduce based on their keys.
     - parameter groupLevel: Control view aggregation of complex keys by setting the number of 
     elements of the key array to use for grouping reduce results.
     - parameter stale: Whether stale views are ok, or should be updated after the response is returned.
     - parameter includeLastUpdateSequenceNumber: Include the squence number from which the view was last built.
     - parameter rowHandler: optional handler to call for each row in the response.
     - parameter completionHandler: optional handler to call when the operation completes.
     
     - warning: `stale` is an advanced option, it should not be used unless you fully understand the outcome of changing the value of this property.
     - warning: The option `key` and `keys` cannot be used together.
     - warning: The `group` option is only valid when a `reduce` function is used.
     - warning: The `groupLevel` option is only valid if `group` is `true`.
     
     */
    public init(name: String,
                designDocumentID: String,
                databaseName:String,
                descending: Bool? = nil,
                startKey: Any? = nil,
                startKeyDocumentID:String? = nil,
                endKey: Any? = nil,
                endKeyDocumentID: String? = nil,
                inclusiveEnd:Bool? = nil,
                key:Any? = nil,
                keys:[Any]? = nil,
                limit:UInt? = nil,
                skip:UInt? = nil,
                includeDocs:Bool? = nil,
                conflicts:Bool? = nil,
                reduce:Bool? = nil,
                group:Bool? = nil,
                groupLevel:UInt? = nil,
                stale:Stale? = nil,
                includeLastUpdateSequenceNumber: Bool? = nil,
                rowHandler:(([String: Any]) -> Void)? = nil,
                completionHandler: (( [String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.databaseName = databaseName
        self.name = name
        self.designDocumentID = designDocumentID
        self.descending = descending
        self.startKey = startKey
        self.startKeyDocumentID = startKeyDocumentID
        self.endKey = endKey
        self.endKeyDocumentID = endKeyDocumentID
        self.inclusiveEnd = inclusiveEnd
        self.key = key
        self.keys = keys
        self.limit = limit
        self.skip = skip
        self.includeDocs = includeDocs
        self.conflicts = conflicts
        self.reduce = reduce
        self.group = group
        self.groupLevel = groupLevel
        self.stale = stale
        self.includeLastUpdateSequenceNumber = includeLastUpdateSequenceNumber
        self.rowHandler = rowHandler
        self.completionHandler = completionHandler
    }
    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    
    public let databaseName: String


    public let designDocumentID: String

    public let name: String

    public let descending: Bool?

    public let startKey: Any?

    public let startKeyDocumentID: String?

    public let endKey: Any?

    public let endKeyDocumentID: String?

    public let inclusiveEnd: Bool?

    public let key: Any?

    public let keys: [Any]?

    public let limit: UInt?

    public let skip: UInt?

    public let includeDocs: Bool?
    
    public let conflicts: Bool?

    /**
     Use the reduce function for the view.
     */
    public let reduce: Bool?

    /**
     Group the results of a reduce based on their keys.
     */
    public let group: Bool?

    /**
     Control view aggregation of complex keys by setting the number of elements of the key array to use for grouping reduce results.

     For example, if the view emits complex keys of the form `["A", "B", "C"]` and is using a `_count` reduce function then setting `groupLevel` would have these effects:
     * `view.groupLevel = 3` would produce rows of the form `{ "key" : ["A", "B", "C"], "value" : n }` where `n` is the count of documents with key `["A", "B", "C"]
     * `view.groupLevel = 1` would produces rows of the form `{ "key" : ["A"], "value" : m }` where `m` is the aggregated count of all keys with "A" as the first element


     */
    public let groupLevel: UInt?


    public let stale: Stale?
    
    public let includeLastUpdateSequenceNumber: Bool?

    /**
     Sets a handler to run for each row retrieved by the view.

     - parameter row: dictionary of the JSON data from the view row
     */
    public let rowHandler: (([String: Any]) -> Void)?

    public func validate() -> Bool {

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
                let keysDict = ["keys": keys]
                let keysJson = try JSONSerialization.data(withJSONObject: keysDict)
                return keysJson
            } catch {
                callCompletionHandler(error: error)
            }
        }
        return nil
    }

    public var endpoint: String {
        return "/\(self.databaseName)/_design/\(designDocumentID)/_view/\(name)"
    }

    public var parameters: [String: String] {
        get {
            var items: [String: String] = makeParams()

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
            keyJson = try jsonValue(for: key)
        }
        if let endKey = endKey {
            endKeyJson = try jsonValue(for: endKey)
        }

        if let startKey = startKey {
            startKeyJson = try jsonValue(for: startKey)
        }

    }

}
