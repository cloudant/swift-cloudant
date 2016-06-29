//
//  GetDocumentOperation.swift
//  SwiftCloudant
//
//  Created by Stefan Kruger on 04/03/2016.
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

public class GetDocumentOperation: CouchDatabaseOperation, JsonOperation {

    public init() { }
    
    public var completionHandler: ((response: [String : AnyObject]?, httpInfo: HTTPInfo?, error: ErrorProtocol?) -> Void)?
    
    public var databaseName: String?
    
    /**
     Include all revisions of the document.
     `true` to include revisions, `false` to not include revisions, leave as `nil` to not emit
     into the json.
     */
    public var revs: Bool? = nil

    /**
     The revision at which you want the document.

     Optional: If omitted CouchDB will return the
     document it determines is the current winning revision
     */
    public var revId: String? = nil

    /**
     The document that this operation will access or modify.

     Must be set before a call can be successfully made.
     */
    public var docId: String? = nil

    public func validate() -> Bool {
        return databaseName != nil && docId != nil
    }

    public var endpoint: String {
        return "/\(self.databaseName!)/\(docId!)"
    }

    public var parameters: [String:  String] {
        get {
            var items: [String: String] = [:]

            if let revId = revId {
                items["rev"] = revId
            }

            if let revs = revs {
                items["revs"] = "\(revs)"
            }

            return items
        }
    }

}
