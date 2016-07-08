//
//  GetAllDocumentsOperation.swift
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
 
 An operation to query database for all documents.
 
 Example usage:
 ```
 let queryOp = GetAllDocumentsOperation()
 queryOp.databaseName = dbName
 queryOp.includeDocs = true // optional
 queryOp.completionHandler = {(response, httpInfo, error) in
   if error != nil {
    // Example: handle an error by printing a message
    print("Error: \(error)")
   } else {
    print("Response: \(response)")
   }
 }
 
 // Add the operation to the database operation queue
 dbClient.add(operation: queryOp)
 ```
 */
public class GetAllDocumentsOperation: CouchDatabaseOperation, JsonOperation {
  
  public init() { }
  
  public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: ErrorProtocol?) -> Void)?
  public var databaseName: String?
  
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
   Stop the view returning result rows when the specified key is reached.
   
   - Note: Optional, if the property is unset this parameter will be omitted from the request and the server default will apply.
   */
  public var endKey: AnyObject? = nil
  
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
   Sets a handler to run for each row retrieved by the view.
   
   - parameter row: dictionary of the JSON data from the view row
   */
  public var rowHandler: ((row: [String: AnyObject]) -> Void)?
  
  public func validate() -> Bool {
    
    if databaseName == nil {
      return false
    }

    // Only one of key or keys can be used
    if key != nil && keys != nil {
      return false
    }

    return true
  }
  
  public var method: String {
    if (keys != nil) {
      return "POST"
    } else {
      return "GET"
    }
  }
  
  public var data: NSData? {
    if let keys = keys {
      do {
        #if os(Linux)
          let keysDict: NSDictionary = ["keys".bridge() : keys.bridge()]
        #else
          let keysDict: NSDictionary = ["keys": keys as NSArray]
        #endif
        let keysJson = try NSJSONSerialization.data(withJSONObject: keysDict)
        return keysJson
      } catch {
        callCompletionHandler(error: error)
      }
    }
    return nil
  }
  
  public var endpoint: String {
    return "/\(self.databaseName!)/_all_docs"
  }
  
  public var parameters: [String: String] {
    get {
      var items: [String: String] = [:]
      
      if let descending = descending {
        items["descending"] = "\(descending)"
      }
      
      if let startKeyJson = startKeyJson {
        items["startkey"] = startKeyJson
      }
      
      if let endKeyJson = endKeyJson {
        items["endkey"] =  endKeyJson
      }
      
      if let inclusiveEnd = inclusiveEnd {
        items["inclusive_end"] = "\(inclusiveEnd)"
      }
      
      if let keyJson = keyJson {
        items["key"] = keyJson
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
  
  public func processResponse(json: Any) {
    if let json = json as? [String: AnyObject] {
      let rows = json["rows"] as! [[String: AnyObject]]
      for row: [String: AnyObject] in rows {
        self.rowHandler?(row: row)
      }
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
