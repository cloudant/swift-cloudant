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
	An enum representing the possible index types for Query.
*/
public enum IndexType : String {
	/**
		Represents the json index type.
	*/
	case JSON = "json"
	/**
		Represents the text Index type.
	*/
	case Text = "text"
}

/**
	An operation to delete a Query index.

	- Requires: The `designDoc`, `indexName` and `type` properties to be set.
	
	Example usage:
	```
	let deleteIndex = DeleteQueryIndexOperation()
	deleteIndex.designDoc = "exampleDesignDoc"
	deleteIndex.indexName = "exampleIndexName"
	deleteIndex.type = .JSON
	deleteIndex.completionHandler = {(response, httpInfo, error) in 
		if error != nil {
        	// Example: handle an error by printing a message
        	print("Error")
    	}
	}

	database.add(operation: deleteIndex)
	```
 */
public class DeleteQueryIndexOperation: CouchDatabaseOperation {

	/**
		The name of the design document which contains the index.
	 */
	public var designDoc: String?

	/**
		The name of the index to delete.
	*/
	public var indexName: String?

	/**
		The type of index e.g. JSON
	*/
	public var type: IndexType?

	public override var httpPath: String {
	 	return "/\(self.databaseName!)/_index/\(self.designDoc!)/\(self.type!.rawValue)/\(self.indexName!)"
	}

	public override var  httpMethod: String {
	 	return "DELETE"
	}

	public override func validate() -> Bool {
		if !super.validate() {
	 		return false
	 	}

	 	return self.designDoc != nil && self.indexName != nil && self.type != nil
	}
}
