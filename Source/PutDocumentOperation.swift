//
//  PutDocumentOperation.swift
//  SwiftCloudant
//
//  Created by stefan kruger on 05/03/2016.
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

public class PutDocumentOperation: CouchDatabaseOperation {
    /**
     The document that this operation will modify.

     Must be set before a call can be successfully made.
     */
    public var docId: String? = nil

    /**
     If updating a document, set this value to the current revision ID.
     */
    public var revId: String? = nil

    /** Body of document. Must be serialisable with NSJSONSerialization */
    public var body: [String: AnyObject]? = nil

    public override func validate() -> Bool {
        return super.validate() && docId != nil && body != nil && NSJSONSerialization.isValidJSONObject(body! as NSDictionary)
    }

    public override var httpMethod: String {
        return "PUT"
    }

    public override var httpRequestBody: NSData? {
        get {
            do {
                let data = try NSJSONSerialization.data(withJSONObject: body! as NSDictionary, options: NSJSONWritingOptions())
                return data
            } catch {
                return nil
            }
        }
    }

    public override var httpPath: String {
        return "/\(self.databaseName!)/\(docId!)"
    }

    public override var queryItems: [NSURLQueryItem] {
        get {
            var items: [NSURLQueryItem] = []

            if let revId = revId {
                items.append(NSURLQueryItem(name: "rev", value: "\(revId)"))
            }

            return items
        }
    }

}
