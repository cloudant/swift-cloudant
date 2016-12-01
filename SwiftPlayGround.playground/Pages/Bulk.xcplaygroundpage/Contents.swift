//: [Previous](@previous)

import Foundation
import SwiftCloudant
import Darwin

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
 `let (rows, response, info) = try db.allDocuments()`
 */
try db.allDocuments {
    print($0)
}


/*:
 
 ### Query
 
 If a specific record(s) needs to be found in the database but the document ID is not known, the document can be found using `find` whichs invokes
 the (Mango) Query function of the server (CouchDB 2.0 / Cloudant only).
 
 Although Query works without first creating an index, it is recommended for faster response times to create a index for the fields
 that you are using for the query.
 
  - Important: It is possible to query for documents without creating an index, however this is signficantly slower than using an index. It is **recommended**
  to create an index for queries used by your application in production.
 
 For this example, we will create an index for the field `number` with an ascending sort.
 */
do {
    try db.createIndex(fields: [Sort(field: "number", sort: .asc)])
} catch {
    print(error)
}

/*:
 With the Index created, we can now query the data set with better performance than we could without the index. For our query, the document which contains the field "number" with the random value
 generated. `["number": value]` is shorthand for `["number":[["$eq": value]]`, both queries will return the same results.
 */

let value = arc4random_uniform(51)
let selector = ["number":value]
let queryResult = try db.find(selector: selector)

for document in queryResult.docs {
    print(document)
}

/*:
 ### Views
 
 Views can also be used to get documents in bulk from the server, however views also contain the ability to reduce the results into a single value.
 Views are contained with design documents. Design Documents are regular documents, but the contain special fields for defining views amongst other things.
 Design Documents can be created using the normal document manipulation methods, but their id needs to be prefixed with `_design/`.
 */
let viewDoc:[String: Any] = ["_id":"_design/testview", "views": ["test": ["map":"function(doc){ emit(doc._id, doc.number);}"]]]
let (viewResponse, _) = try db.save(document: viewDoc)


/*:
 #### Querying Views
 
 For a simplistic view query which returns all the rows in the view only requires the name of the view and the design document in which it is located.
 */
let viewResp = try db.queryView(name: "test", designDocumentID: "testview")
for row in viewResp.rows {
    print(row)
}


//: [Next](@next)
