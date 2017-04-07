//
//  ViewPaging.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 01/08/2016.
//
//  Copyright (C) 2016 IBM Corp.
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
 ViewPager makes it possible to paginate results from a CouchDB view.
 There are some issues to be aware of when paginating  views.
 
 Views do not support pagination natively, `ViewPager` paginates views using the `startKey`,
 `startKey_docid`, `endKey`, `endKey_docid` and `limit` parameters to return a set number
 of results or less. Each time a page is requested using the pageHandler closure, by returning
 `ViewPager.Page.next` or `.previous` a new request is made to the server.
 
 - warning: Paginating through views using multiple requests can cause results to be missed
 if they are inserted at the boundry of a page between page requests. 
 Additionally multiple requests may present inconsistent results for the same apparent page when 
 a repeat request is made (e.g. paging back to a previous page) if results have been inserted or
 removed inbetween the page requests.
 
 Usage Example:
 
 ```
 // Make the first request with a view pager.
 let pager = ViewPager(name: "exampleView", designDocumentID: "example", database: "exampleDB, client: client) { (response, token, error) -> .Page? 
 
    //process the results
    if someCondition {
       return nil // return nil to stop page
    } else {
        return .next
    }
 
 }
 
 pager.makeRequest()
 
 
 // Get the next page from a token.
 
 ViewPager.next(token: token) { (response, token, error) -> .Page? in 
 
    //process the results
    if someCondition {
        return nil // return nil to stop requesting pages
    } else {
        return .next // to request the next page
    }
 }
 
 // Get the previous page from a string token
 let strToken = try token.serialise
 
 try ViewPager.next(token: strToken) { (response, token, error) -> .Page? in
 
    //process the results
    if someCondition {
        return nil // return nil to stop page
    } else {
        return .previous
    }
 }
 ```
 
 - seealso:
 [CouchDB Pagination Recipe](http://docs.couchdb.org/en/stable/couchapp/views/pagination.html)
*/
public class ViewPager {
    /**
     A token which contains all the information required to continue paging for a previous
     `ViewPager`.
     */
    public struct Token {
        
        fileprivate let state: ViewPager.State
        
        fileprivate let descending: Bool?
        fileprivate let startKey: Any?
        fileprivate let startKeyDocumentID:String?
        fileprivate let endKey: Any?
        fileprivate let endKeyDocumentID: String?
        fileprivate let inclusiveEnd:Bool?
        fileprivate let key:Any?
        fileprivate let keys:[Any]?
        fileprivate let includeDocs:Bool?
        fileprivate let conflicts:Bool?
        fileprivate let stale:Stale?
        fileprivate let includeLastUpdateSequenceNumber: Bool?
        
        fileprivate let name: String
        fileprivate let designDocumentID: String
        fileprivate let databaseName:String
        fileprivate let pageSize:UInt
        
        fileprivate let client: CouchDBClient
        
        
        /**
         Creates a serialised version of this token.
         
         - throws: An error if serialisation fails.
         
         - returns: A serialised version of this token.
        */
        public func serialised() throws -> String {
            
            var dict:[String: Any] = ["name": name,
                                        "ddoc": designDocumentID,
                                        "db": databaseName,
                                        "page_size": pageSize]
            
            
            if let descending = descending {
                dict["descending"] = descending
            }
            if let startKey = startKey {
                dict["startkey"] = startKey
            }
            
            if let startKeyDocumentID = startKeyDocumentID {
                dict["startkey_docid"] = startKeyDocumentID
            }
            
            if let endKey = endKey {
                 dict["endkey"] = endKey
            }
            
            if let endKeyDocumentID = endKeyDocumentID {
                dict["endkey_docid"] = endKeyDocumentID
            }
            
            if let inclusiveEnd = inclusiveEnd {
                dict["inclusive_end"] = inclusiveEnd
            }
            
            if let key = key {
                dict["key"] = key
            }
            
            if let keys = keys {
                dict["keys"] = keys
            }
            
            if let includeDocs = includeDocs {
                dict["include_docs" ] = includeDocs
            }
            
            if let conflicts = conflicts {
                dict["conflicts"] = conflicts
            }
            
            if let stale = stale {
                dict["stale" ] = "\(stale)"
            }
            
            if let includeLastUpdateSequenceNumber = includeLastUpdateSequenceNumber {
                dict["update_seq"] = includeLastUpdateSequenceNumber
            }
            
            dict["state"] = state.dictionary

            
            let data = try JSONSerialization.data(withJSONObject: dict)
            return data.base64EncodedString()
        }
        
        fileprivate static func from(_ string: String, with client: CouchDBClient) throws -> Token {
            guard let data = Data(base64Encoded: string),
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                else {
                    throw Error.deseralisationFailure
            }
            
            let stateDict = dict["state"] as! [String: Any]
            let state = State.from(stateDict)
            
            let stale: Stale?
            if let staleString = dict["stale"] as? String {
                switch staleString {
                case "ok":
                    stale = .ok
                    break
                case "update_after":
                    stale = .updateAfter
                    break
                default:
                    throw Error.deseralisationFailure
                }
            } else {
                stale = nil
            }
            
            return Token(state: state,
                         descending: dict["descending"] as? Bool,
                         startKey: dict["startkey"],
                         startKeyDocumentID:  dict["startkey_docid"] as? String,
                         endKey: dict["endkey"],
                         endKeyDocumentID: dict["endkey_docid"] as? String,
                         inclusiveEnd: dict["inclusive_end"] as? Bool,
                         key: dict["key"],
                         keys: dict["keys"] as? [Any],
                         includeDocs: dict["include_docs"] as? Bool,
                         conflicts: dict["conflicts"] as? Bool,
                         stale: stale ,
                         includeLastUpdateSequenceNumber: dict["update_seq"] as? Bool,
                         name: dict["name"] as! String,
                         designDocumentID: dict["ddoc"] as! String,
                         databaseName: dict["db"] as! String,
                         pageSize: dict["page_size"] as! UInt,
                         client: client)
        }
        
    }
    
    /**
     A enum to indicate the page thats should retrieved from the view.
     */
    public enum Page: String {
        /** The next page */
        case next = "next"
        /** the previous page */
        case previous = "previous"
    }
    
    /**
     A enum to indicate the current direction of pagination.
     */
    private enum Direction {
        /** paging in the forward direction */
        case forward
        /** paging in the backward direction */
        case backward
    }
    
    /**
     The errors that can be thrown when serialising and deserialising the token.
     */
    public enum Error : Swift.Error {
        /** An error occurred serialising the token **/
        case seralisationFailure
        /** An error occurred deserialising the token **/
        case deseralisationFailure
    }
    
    /**
     A container for the current state of pagination
     */
    fileprivate struct State {
        var lastEndKey: Any?
        var lastEndKeyDocID: String?
        
        var lastStartKey: Any?
        var lastStartKeyDocID: String?
        
        var lastPageDirection: Page?
        
        fileprivate var dictionary: [String: Any] {
            get {
                var dict: [String: Any] = [:]
                if let lastEndKey = lastEndKey {
                    dict["last_endkey"] = lastEndKey
                }
                
                if let lastEndKeyDocID = lastEndKeyDocID {
                    dict["last_endkey_docid"] = lastEndKeyDocID
                }
                
                if let lastStartKey = lastStartKey {
                    dict["last_startkey"] = lastStartKey
                }
                
                if let lastStartKeyDocID = lastStartKeyDocID {
                    dict["last_startkey_docid"] = lastStartKeyDocID
                }
                if let lastPageDirection = lastPageDirection {
                    dict["last_page"] = lastPageDirection.rawValue
                }
                
                return dict
            }
        }
        
        fileprivate static func from(_ dict: [String:Any]) -> State {
            let lastPage: Page?
            switch dict["last_page"] as! String {
                case "next":
                    lastPage = .next
                    break
                case "previous" :
                    lastPage = .previous
                default:
                    lastPage = nil
            }
            return State(lastEndKey: dict["last_endkey"],
                         lastEndKeyDocID: dict["last_endkey_docid"] as? String,
                         lastStartKey: dict["last_startkey"],
                         lastStartKeyDocID: dict["last_startkey_docid"] as? String,
                         lastPageDirection: lastPage)
        }
    }
    
    private let pageHandler: ([String : Any]?,Token?,Swift.Error?) -> Page?
    
    private let rowHandler: (([String: Any]) -> Void)?
    
    private let pageSize: UInt
    
    private let client: CouchDBClient
    
    /// MARK: User provided parameters for the view Op.
    private let descending: Bool?
    private let startKey: Any?
    private let startKeyDocumentID:String?
    private let endKey: Any?
    private let endKeyDocumentID: String?
    private let inclusiveEnd:Bool?
    private let key:Any?
    private let keys:[Any]?
    private let includeDocs:Bool?
    private let conflicts:Bool?
    private let stale:Stale?
    private let includeLastUpdateSequenceNumber: Bool?
    
    private let name: String
    private let designDocumentID: String
    private let databaseName:String
    
    /// MARK: state properties for generating the next page etc.
    private var state: State = State()
    
    
    /**
     Creates a view pager
    
     - parameter name:                            The name of the view
     - parameter designDocumentID:                The ID of the design document (without _design/ prefix) which contains the view.
     - parameter databaseName:                    The name of the database that contains the view.
     - parameter client:                          The client that should be used to make requests.
     - parameter pageSize:                        The number of results per page, default 25. The value can be no more than UInt.max - 1.
     - parameter descending:                      Return the view in descending key order.
     - parameter startKey:                        The key from where results should start being returned from.
     - parameter startKeyDocumentID:              The document ID to be paired with the `startKey` to indicate the starting place when there are duplicate keys.
     - parameter endKey:                          The key where the view should stop returning results.
     - parameter endKeyDocumentID:                The document ID to be paired with the `endKey` to indicate the place to end when there are duplicate keys.
     - parameter inclusiveEnd:                    should `endkey` be returned in the results.
     - parameter key:                             Return entires that match the specified key.
     - parameter keys:                            Return entires that match the specified keys.
     - parameter includeDocs:                     Include document content in the response.
     - parameter conflicts:                       Include conflict information in the response.
     - parameter stale:                           Whether stale views are ok, or should be updated after the response is returned.
     - parameter includeLastUpdateSequenceNumber: Include the last update sequence number for the view in the response.
     - parameter rowHandler:                      A closure to call for each row in the response.
     - parameter pageHandler:                     A closure to call for each response from the server. Returning `nil` instead of a `ViewPager.Page`
     will result in the view pager stop paging through results.
    
     - seeAlso:
        QueryViewOperation for full details on the parameters that can be passed to a view.
     
     */
    public init(name: String,
                designDocumentID: String,
                databaseName:String,
                client: CouchDBClient,
                pageSize: UInt = 25,
                descending: Bool? = nil,
                startKey: Any? = nil,
                startKeyDocumentID:String? = nil,
                endKey: Any? = nil,
                endKeyDocumentID: String? = nil,
                inclusiveEnd:Bool? = nil,
                key:Any? = nil,
                keys:[Any]? = nil,
                includeDocs:Bool? = nil,
                conflicts:Bool? = nil,
                stale:Stale? = nil,
                includeLastUpdateSequenceNumber: Bool? = nil,
                rowHandler:(([String: Any]) -> Void)? = nil,
                pageHandler: @escaping ([String : Any]?,Token?,Swift.Error?) -> Page?) {
        
        self.name = name
        self.designDocumentID = designDocumentID
        self.databaseName = databaseName
        self.pageSize = pageSize
        self.pageHandler = pageHandler
        self.rowHandler = rowHandler
        self.client = client
        self.descending = descending
        self.startKey = startKey
        self.startKeyDocumentID = startKeyDocumentID
        self.endKey = endKey
        self.endKeyDocumentID = endKeyDocumentID
        self.inclusiveEnd = inclusiveEnd
        self.key = key
        self.keys = keys
        self.includeDocs = includeDocs
        self.conflicts = conflicts
        self.stale = stale
        self.includeLastUpdateSequenceNumber = includeLastUpdateSequenceNumber
    }
    
    /**
     Asynchonrously make the first request to the view.
     */
    public func makeRequest() {
        self.makeRequest(page: nil)
    }
    

    /**
     Makes a query view request.
     
     - parameter page: the page to request or `nil` if it is the first page.
     */
    private func makeRequest(page: Page?) {
        
        let startKey: Any?
        let startKeyDocumentID: String?
        let endKey: Any?
        let endKeyDocumentID: String?
        let descending: Bool?
        let inclusiveEnd: Bool?
        
        if let page = page {

            switch (page){
            case .next where self.state.lastPageDirection == .next || self.state.lastPageDirection == nil:
                startKey = self.state.lastEndKey
                startKeyDocumentID = self.state.lastEndKeyDocID
                endKey = self.endKey
                endKeyDocumentID = self.endKeyDocumentID
                descending = self.descending
                inclusiveEnd = self.inclusiveEnd
                break
            case .previous:
                startKey = self.state.lastStartKey
                startKeyDocumentID = self.state.lastStartKeyDocID
                endKey = self.startKey
                endKeyDocumentID = self.startKeyDocumentID
                descending = self.descending == nil ? true : nil
                inclusiveEnd = true
                break
                
            case .next where self.state.lastPageDirection == .previous:
                startKey = self.state.lastStartKey
                startKeyDocumentID = self.state.lastStartKeyDocID
                endKey = self.endKey
                endKeyDocumentID = self.endKeyDocumentID
                descending = self.descending
                inclusiveEnd = self.inclusiveEnd
                break
                
            default:
                abort() // aborting for now, when this is finished we should never hit this.
                break
            }
            self.state.lastPageDirection = page
        } else {
            startKey = self.startKey
            startKeyDocumentID = self.startKeyDocumentID
            endKey = self.endKey
            endKeyDocumentID = self.endKeyDocumentID
            descending = self.descending
            inclusiveEnd = self.inclusiveEnd
        }
        
        // This deliberately causes a retain cycle for `self`. This is so the async class
        // methods do not need to return the ViewPager to be retained by calling classes.
        // The view Pager will be released when the underlying operation is released.
        let viewOp = QueryViewOperation(name: name,
                                        designDocumentID: designDocumentID,
                                        databaseName: databaseName,
                                        descending: descending,
                                        startKey: startKey,
                                        startKeyDocumentID: startKeyDocumentID,
                                        endKey: endKey,
                                        endKeyDocumentID: endKeyDocumentID,
                                        inclusiveEnd: inclusiveEnd,
                                        key: key,
                                        keys: keys,
                                        limit: pageSize + UInt(1),
                                        skip: 0,
                                        includeDocs: includeDocs,
                                        conflicts: conflicts,
                                        reduce: false,
                                        stale: stale,
                                        includeLastUpdateSequenceNumber: includeLastUpdateSequenceNumber)
        { (response, httpInfo, error) in
                if let response = response, let rows = response["rows"] as? [[String: Any]] {
                    
                    let filteredRows: [[String: Any]]
                    
                    if let last = rows.last {
                        self.state.lastEndKey = last["key"]
                        self.state.lastEndKeyDocID = last["id"] as? String
                    }
                    
                    if let first = rows.first {
                        self.state.lastStartKey = first["key"]
                        self.state.lastStartKeyDocID = first["id"] as? String
                    }
                    
                    // we should only filter last if we are going forward, if backwards we need to filter the first.
                    if rows.count > Int(self.pageSize) {
                        if page == .next || page == nil {
                            filteredRows = Array(rows.dropLast())
                        } else {
                            filteredRows = Array(rows.dropFirst()).reversed()
                        }
                    } else {
                        filteredRows = rows
                    }
                    
                    // call the row handler.
                    for row in filteredRows {
                        self.rowHandler?(row)
                    }
                    
                    var requestedResponse = response
                    requestedResponse["rows"] = filteredRows
                    
                    if let returned = self.pageHandler(requestedResponse, self.makeToken(), error) {
                        self.makeRequest(page: returned)
                    }
                    
                } else {
                    if let _ =  self.pageHandler(nil, self.makeToken(), error) {
                        print("Next and previous states not allowed")
                    }
                }
        }
        
        client.add(operation: viewOp)
        
    }
    
    private func makeToken() -> Token {
        return Token(state: self.state,
                         descending: self.descending,
                         startKey: self.startKey,
                         startKeyDocumentID: self.startKeyDocumentID,
                         endKey: self.endKey,
                         endKeyDocumentID: self.endKeyDocumentID,
                         inclusiveEnd: self.inclusiveEnd,
                         key: self.key,
                         keys: self.keys,
                         includeDocs: self.includeDocs,
                         conflicts: self.conflicts,
                         stale: self.stale,
                         includeLastUpdateSequenceNumber: self.includeLastUpdateSequenceNumber,
                         name: self.name,
                         designDocumentID: self.designDocumentID,
                         databaseName: self.databaseName,
                         pageSize: self.pageSize,
                         client: self.client)
    }
    
    /**
     Asynchronously requests the next page, using a `Token` from a previous `ViewPager`.
     
     - parameter token: The token from a previous `ViewPager`.
     - parameter rowHandler: A closure to run for each row for the page.
     - parameter pageHandler: A clousre to run when the page is retrieved from the server. The `pageHandler`
     returning `nil` will indicate that the `ViewPager` should not make any more requests.
    */
    public class func next(token: Token,
                           rowHandler:(([String: Any]) -> Void)? = nil,
                           pageHandler: @escaping ([String : Any]?, Token?, Swift.Error?) -> Page?) {
        
        ViewPager.makePage(token: token, page: .next, rowHandler: rowHandler, pageHandler: pageHandler)
        
    }
    
    /**
     Asynchronously requests the previous page, using a `Token` from a previous `ViewPager`.
     
     - parameter token: The token from a previous `ViewPager`.
     - parameter rowHandler: A closure to run for each row for the page.
     - parameter pageHandler: A closure to run when the page is retrieved from the server. The `pageHandler`
     returning `nil` will indicate that the `ViewPager` should not make any more requests.
     */
    public class func previous(token: Token,
                               rowHandler:(([String: Any]) -> Void)? = nil,
                               pageHandler: @escaping ([String : Any]?, Token?, Swift.Error?) -> Page?){
        ViewPager.makePage(token: token, page: .previous, rowHandler: rowHandler, pageHandler: pageHandler)
    }
    
    /**
     Asynchronously requests the next page, using a `Token` from a previous `ViewPager`.
     
     - parameter token: The serialised representation of a `Token` from a previous `ViewPager`.
     - parameter client: The client to use when making the paging request.
     - parameter rowHandler: A closure to run for each row for the page.
     - parameter pageHandler: A closure to run when the page is retrieved from the server. The `pageHandler`
     returning `nil` will indicate that the `ViewPager` should not make any more requests.
     */
    public class func next(token: String,
                           client: CouchDBClient,
                           rowHandler:(([String: Any]) -> Void)? = nil,
                           pageHandler: @escaping ([String : Any]?, Token?, Swift.Error?) -> Page?) throws {
        let token = try Token.from(token, with: client)
        ViewPager.next(token: token, rowHandler: rowHandler, pageHandler: pageHandler)
    }
    
    /**
     Asynchronously requests the previous page using `Token` from a previous `ViewPager`.
     
     - parameter token: The serialised representation of a `Token` from a previous `ViewPager`.
     - parameter client: The client to use when making the paging request.
     - parameter rowHandler: A closure to run for each row for the page.
     - parameter pageHandler: A closure to run when the page is retrieved from the server. The `pageHandler`
     returning `nil` will indicate that the `ViewPager` should not make any more requests.
     */
    public class func previous(token: String,
                               client: CouchDBClient,
                               rowHandler:(([String: Any]) -> Void)? = nil,
                               pageHandler: @escaping ([String : Any]?, Token?, Swift.Error?) -> Page?) throws {
        let token = try Token.from(token, with: client)
        ViewPager.previous(token: token, rowHandler: rowHandler, pageHandler: pageHandler)
    }
    
    private class func makePage(token: Token,
                                  page:Page,
                                  rowHandler:(([String: Any]) -> Void)?,
                                  pageHandler: @escaping ([String : Any]?, Token?, Swift.Error?) -> Page?) {
        let viewPage = ViewPager(name: token.name,
                            designDocumentID: token.designDocumentID,
                            databaseName: token.databaseName,
                            client: token.client,
                            pageSize: token.pageSize,
                            descending: token.descending,
                            startKey: token.startKey,
                            startKeyDocumentID: token.startKeyDocumentID,
                            endKey: token.endKey,
                            endKeyDocumentID: token.endKeyDocumentID,
                            inclusiveEnd: token.inclusiveEnd,
                            key: token.key,
                            keys: token.keys,
                            includeDocs: token.includeDocs,
                            conflicts: token.conflicts,
                            stale: token.stale,
                            includeLastUpdateSequenceNumber: token.includeLastUpdateSequenceNumber,
                            rowHandler: rowHandler,
                            pageHandler: pageHandler)
        viewPage.state.lastEndKey = token.state.lastEndKey
        viewPage.state.lastEndKeyDocID = token.state.lastEndKeyDocID
        viewPage.state.lastStartKey = token.state.lastStartKey
        viewPage.state.lastStartKeyDocID = token.state.lastStartKeyDocID
        viewPage.state.lastPageDirection = token.state.lastPageDirection
        
        
        viewPage.makeRequest(page: page)
    }
    
    
    
}




