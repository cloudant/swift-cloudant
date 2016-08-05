//
//  DeleteQueryIndexOperation.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 17/05/2016.
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
	An operation to delete a Query index.
	
	Example usage:
	```
	let deleteIndex = DeleteQueryIndexOperation(name: "exampleIndexName",
                                                type: .JSON, 
                                    designDocumentID: "exampleDesignDoc",
                                        databaseName: "exampledb"){(response, httpInfo, error) in
		if error != nil {
        	// Example: handle an error by printing a message
        	print("Error")
    	}
	}

	client.add(operation: deleteIndex)
	```
 */
public class DeleteQueryIndexOperation: CouchDatabaseOperation, JSONOperation {
    
    /**
     An enum representing the possible index types for Query.
     */
    public enum `Type` : String {
        /**
         Represents the json index type.
         */
        case json = "json"
        /**
         Represents the text Index type.
         */
        case text = "text"
    }
    
    /**
    
     Creates the operation.
     
     - parameter name: the name of the index to delete
     - parameter type: the type of the index that is being deleted.
     - parameter designDocumentID: the ID of the design document that contains the index.
     - parameter databaseName: the name of the database that contains the design document.
     - parameter completionHandler: optional handler to run when the operation completes.
     */
    public init(name: String, type: Type, designDocumentID: String, databaseName: String, completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)? = nil) {
        self.name = name
        self.type = type
        self.designDocumentID = designDocumentID
        self.databaseName = databaseName
        self.completionHandler = completionHandler
    }
    
    public let completionHandler: (([String : Any]?, HTTPInfo?, Error?) -> Void)?
    public let databaseName: String

	/**
		The name of the design document which contains the index.
	 */
	public let designDocumentID: String

	/**
		The name of the index to delete.
	*/
	public let name: String

	/**
		The type of index e.g. JSON
	*/
	public let type: Type

	public var endpoint: String {
	 	return "/\(self.databaseName)/_index/\(self.designDocumentID)/\(self.type.rawValue)/\(self.name)"
	}

	public var  method: String {
	 	return "DELETE"
	}

}
