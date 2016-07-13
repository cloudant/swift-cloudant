//
//  ViewLikeOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 06/07/2016.
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


// This Can't be defined in the extension or the protocol defining outside for now.
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
 Denotes an operation that performs actions on a view.
 Some operations are not strictly a view externally, but internally
 they are effectively a view and have similar parameters.
 */
public protocol ViewOperation : CouchDatabaseOperation {
    associatedtype ViewParameter
    
    /**
     Return the result rows in 'descending by key' order.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    var descending: Bool? { get set }
    
    /**
     Return key/value result rows starting from the specified key.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    var startKey: ViewParameter? { get set }
    
    /**
     Used in conjunction with startKey to further restrict the starting row for
     cases where two documents emit the same key. Specifying the doc ID allows
     the view to return result rows from the specified start key and document.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
     */
    var startKeyDocId: String? { get set }
    
    /**
     Stop the view returning result rows when the specified key is reached.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     */
    var endKey: ViewParameter? { get set }
    
    /**
     Used in conjunction with endKey to further restrict the ending row for cases
     where two documents emit the same key. Specifying the doc ID allows the view
     to return result rows up to the specified end key and document.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     */
    var endKeyDocId: String? { get set }
    
    /**
     Include result rows with the specified `endKey`.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     */
    var inclusiveEnd: Bool? { get set }
    
    /**
     Return only result rows that match the specified key.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     
     - Warning: Cannot be used with `keys` option.
     */
    var key: ViewParameter? { get set }
    
    /**
     Return only result rows that match the specified keys.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     
     - Warning: Cannot be used with `key` option.
     */
    var keys: [ViewParameter]? { get set }
    
    /**
     Limit the number of result rows returned from the view.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     */
    var limit: UInt? { get set }
    
    /**
     The number of rows to skip in the view results.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     */
    var skip: UInt? { get set }
    
    /**
     Include the full content of documents in the view results.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     */
    var includeDocs: Bool? { get set }
    
    /**
     Include informaion about conflicted revisions in the response.
     
     - Note: this can only be used if `includeDocs` is set to `true`.
     */
    var conflicts: Bool? { get set }
    
    /**
     Configures the view request to allow the return of stale results. This allows the view to return
     immediately rather than waiting for the view index to build. When this parameter is omitted (i.e. with the 
     default of `stale=nil`) the server will not return stale results.
     
     - Note: Optional, if the property is unset this parameter will be omitted from the request and the server 
     default will apply.
     - SeeAlso: `Stale` for descriptions of the available values for allowing stale views.
     - Warning: This is an advanced option, it should not be used unless you fully understand the outcome of 
     changing the value of this property.
     */
    var stale: Stale? { get set }
    
    var updateSeq: Bool? { get set }
    
    /**
     Sets a handler to run for each row retrieved by the view.
     
     - parameter row: dictionary of the JSON data from the view row
     */
    var rowHandler: ((row: [String: AnyObject]) -> Void)? { get set }
    
}

public extension ViewOperation {
    
    public func processResponse(json: Any) {
        if let json = json as? [String: AnyObject] {
            let rows = json["rows"] as! [[String: AnyObject]]
            for row: [String: AnyObject] in rows {
                self.rowHandler?(row: row)
            }
        }
    }
    
    public var method: String {
        get {
            if keys != nil {
                return "POST"
            } else {
                return "GET"
            }
        }
    }
    
    /** 
    Generates parameters for the following properties
 
    * descending
    * startKeyDocId
    * endKeyDocId
    * inclusiveEnd
    * limit
    * skip
    * includeDocs
    * conflicts
     
     
    - Note: Implementing types *have* to add parameters which use the `associatedtype` `ViewParameter`
    */
    func generateParams() -> [String : String]{
        var items: [String: String] = [:]
        
        if let descending = descending {
            items["descending"] = "\(descending)"
        }
        
        if let startKeyDocId = startKeyDocId {
            items["startkey_docid"] = startKeyDocId
        }
        
        if let endKeyDocId = endKeyDocId {
            items["endkey_docid"] = "\(endKeyDocId)"
        }
        
        if let inclusiveEnd = inclusiveEnd {
            items["inclusive_end"] = "\(inclusiveEnd)"
        }
        
        if let limit = limit {
            items["limit"] = "\(limit)"
        }
        
        if let skip = skip {
            items["skip"] = "\(skip)"
        }
        
        if let includeDocs = includeDocs {
            items["include_docs"] = "\(includeDocs)"
        }
        
        if let stale = stale {
            items["stale"] = "\(stale)"
        }
        
        if let conflicts = conflicts {
            items["conflicts"] = "\(conflicts)"
        }
        
        if let updateSeq = updateSeq {
            items["update_seq"] = "\(updateSeq)"
        }
        
        return items
    }
    
    func convertJson(key: AnyObject) throws -> String {
        if JSONSerialization.isValidJSONObject(key) {
            let keyJson = try JSONSerialization.data(withJSONObject: key)
            return String(data: keyJson, encoding: .utf8)!
        } else if key is String {
            // we need to quote JSON primitive strings
            return "\"\(key)\""
        } else {
            // anything else we just try as stringified JSON value
            return "\(key)"
        }
    }
}
