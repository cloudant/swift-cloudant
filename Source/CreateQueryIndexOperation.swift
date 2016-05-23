//
//  CreateQueryIndexOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 18/05/2016.
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
    An operation to create a JSON Query (Mango) Index.
 
    Usage example:
    ```
    let index = CreateJsonQueryIndexOperation()
    index.indexName = "exampleIndex"
    index.fields = [Sort(field:"food", sort: .Desc)]
    index.designDoc = "examples"
    index.databaseName = "exampledb"
    index.completionHandler = { (response, httpInfo, error) in
        if let error = error {
            // handle the error
        } else {
            // Check the status code for success.
        }
 
    }
 
    client.add(operation: index)
    ```
 */
public class CreateJsonQueryIndexOperation: CouchDatabaseOperation, MangoOperation, JsonOperation {
    
    public var databaseName: String?
    
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HttpInfo?, error: ErrorProtocol?) -> Void)?
    
    /**
     The name of the index.
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     */
    public var indexName: String?
    
    /**
     The fields to which the index will be applied.
     
     - Note: Required, this parameter needs to be set for the operation to successfully complete.
     */
    public var fields: [Sort]?
    
    /**
     The name of the design doc this index should be saved to.
     
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     */
    public var designDoc: String?

    private var jsonData: NSData?
    
    
    public var method: String {
        return "POST"
    }

    public var data: NSData? {
        return self.jsonData
    }
    
    public var endpoint: String {
        return "/\(self.databaseName!)/_index"
    }
    
    public func validate() -> Bool {
        if databaseName == nil {
            return false
        }
        
        return fields != nil
    }

    public func serialise() throws {

        var jsonDict: [String:AnyObject] = ["type": "json"]

        if let fields = fields {
            var index: [String: AnyObject] = [:]
            index["fields"] = transform(sortArray: fields) as NSArray
            jsonDict["index"] = index as NSDictionary
        }

        if let indexName = indexName {
            jsonDict["name"] = indexName as NSString
        }

        if let designDoc = designDoc {
            jsonDict["ddoc"] = designDoc as NSString
        }


        jsonData = try NSJSONSerialization.data(withJSONObject:jsonDict as NSDictionary) 
    }
    
}

/**
  A struct to represent a field in a Text index.
 */
public struct TextIndexField {
    /**
     The name of the field
    */
    let name: String
    /**
     The type of field.
     */
    let type: TextIndexFieldType
}

/**
    The data types for a field in a Text index.
 */
public enum TextIndexFieldType : String {
    /**
     A Boolean data type.
    */
    case Boolean = "boolean"
    /**
     A String data type.
    */
    case String = "string"
    /**
     A Number data type.
    */
    case Number =  "number"
}

/**
 An Operation to create a Text Query (Mango) Index.
 
 Usage Example:
 ```
 let index = CreateTextQueryIndexOperation()
 index.indexName = "example"
 index.fields = [TextIndexField(name:"food", type: .String)
 index.defaultFieldAnalyzer = "english"
 index.defaultFieldEnabled = true
 index.selector = ["type": "food"]
 index.designDoc = "examples"
 index.databaseName = "exampledb"
 index.completionHandler = { (response, httpInfo, error) in 
    if let error = error {
        // handle the error
    } else {
        // Check the status code for success.
    }
 }
 client.add(operation: index)
 */
public class CreateTextQueryIndexOperation: CouchDatabaseOperation, MangoOperation, JsonOperation {
    
    public var databaseName: String?
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HttpInfo?, error: ErrorProtocol?) -> Void)?
    
    /**
     The name of the index
     
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     */
    public var indexName: String?
    
    /**
     The fields to be included in the index.
     
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     */
    public var fields: [TextIndexField]?
    
    /**
     The name of the analyzer to use for $text operator with this index.
     
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     */
    public var defaultFieldAnalyzer: String?
    
    /**
     If the default field should be enabled for this index.
     
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     
     - Note: If this is not enabled the `$text` operator will **always** return 0 results.
     
     */
    public var defaultFieldEnabled: Bool?
    
    /**
     A selector to limit the documents in the index.
     
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     */
    public var selector: [String: AnyObject]?
    
    /**
     The name of the design doc this index should be included with
     
     - Note: Optional, if this parameter is not set, it will be omitted from the request
     and the server default will apply.
     */
    public var designDoc: String?

    private var jsonData : NSData?
    public  var data: NSData? {
        return jsonData
    }
    
    public var method: String {
        return "POST"
    }
    
    public var endpoint: String {
        return "/\(self.databaseName!)/_index"
    }
    
    public func validate() -> Bool {
        if databaseName == nil {
            return false
        }
        
        if let selector = selector {
            return NSJSONSerialization.isValidJSONObject(selector as NSDictionary)
        }
        
        return true
    }
    
    public func serialise() throws {

        do {
            var jsonDict: [String: AnyObject] = [:]
            var index: [String: AnyObject] = [:]
            var defaultField: [String: AnyObject] = [:]
            jsonDict["type"] = "text"
            
            if let indexName = indexName {
                jsonDict["name"] = indexName as NSString
            }
            
            if let fields = fields {
                index["fields"] = transform(fields: fields)
            }
            
            if let defaultFieldEnabled = defaultFieldEnabled {
                defaultField["enabled"] = defaultFieldEnabled as NSNumber
            }

            if let defaultFieldAnalyzer = defaultFieldAnalyzer {
                defaultField["analyzer"] = defaultFieldAnalyzer as NSString
            }
            
            if let designDoc = designDoc {
                jsonDict["ddoc"] = designDoc as NSString
            }

            if let selector = selector {
                index["selector"] = selector as NSDictionary
            } 

            if defaultField.count > 0 {
                index["default_field"] = defaultField as NSDictionary
            }

            if index.count > 0 {
                jsonDict["index"] = index as NSDictionary
            }

            self.jsonData = try NSJSONSerialization.data(withJSONObject:jsonDict as NSDictionary)

        }
        
    }
    
}

