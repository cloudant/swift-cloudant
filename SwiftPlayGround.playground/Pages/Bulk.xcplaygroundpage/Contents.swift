//: [Previous](@previous)

import Foundation
import SwiftCloudant

let client = CouchDBClient(url: URL(string: "http://localhost:5984")!, username: nil, password: nil)
let db = client.database("test")
try? db.create()
defer {
    try? db.delete()
}

//: ## Bulk 
//: ### Bulk Writes.
//: It is also possible to load the database with documents in bulk. This is perfered if there is a large number of documents that need to be created,
//: updated or deleted.
//: - Note: When deleting documents through the bulk API, the document will need to contain `_deleted` top level key and it needs to be set to true
//: for the document to be deleted.
try db.bulk(documents: generateDocuments(count: 50))

/*:
 ### Reading documents in Bulk.
 
 If all the documents of the database need to be read, this can be doe with an all docs call.
 
 - example: If you wish to get the raw response with all documents for other processing call with 
 no parameters.
 `db.allDocuments()`
 */
try db.allDocuments {
    print($0)
}


/*:
 If a specific record needs to be found in the database but the document ID is not known, the document can be found using `find` whichs invokes
 the (Mango) Query function of the server (CouchDB 2.0 / Cloudant only).
 
 Although Query works without first creating an index, it is reconmended for faster response times to create a index for the fields
 that you are using for the query.
 */
do {
    try db.createIndex(fields: [Sort(field: "foo", sort: .asc)])
} catch {
    print(error)
}
/*:
 The above creates a JSON index, for the field "foo" with a ascending sort. With the index created we can now use it to query for the documents
 which has the field `foo` set to the value `bar`
 */

let selector = ["foo":"bar"]
let queryResult = try db.find(selector: selector)
for document in queryResult.docs {
    print(document)
}

/*:
 Views can also be used to get documents in bulk from the server in addition to this view can be used to
 */
let viewDoc:[String: Any] = ["_id":"_design/testview", "views": ["test": ["map":"function(doc){ emit(doc._id, doc.number);}"]]]


let (viewResponse, _) = try db.save(document: viewDoc)
let viewResp = try db.queryView(name: "test", designDocumentID: "testview")
for row in viewResp.rows {
    print(row)
}




//: [Next](@next)
