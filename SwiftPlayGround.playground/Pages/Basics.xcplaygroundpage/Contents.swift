//: # SwiftCloudant

import Foundation
import SwiftCloudant


/*:
 
  ## Interacting with Cloudant; the basics.
 
 All interactions with a Cloudant account is performed via the `CouchDBClient` class. The client manages authentication so you don't have to.
 If using cloudant your client can be set up with an account, however if you are using a CouchDB or Cloudant Local instance, you can construct
 the client using an URL
 
 - example: Constructing a client to interact with a CouchDB server located on the localhost with the default port (5984).
 
    ` let client = CouchDBClient(url: URL("http://localhost:5984")!, username: nil, password: nil)`
 
 * callout(Reconmendation): It is reconmended that interaction with cloudant in production is through the use of API keys.
 It is important to note however that API keys cannot create or delete databases.

 
 */
let client = CouchDBClient(url: URL(string: "http://localhost:5984")!, username: nil, password: nil)
//let account = "example"
//let username = "example"
//let password = "eample"
//let client = CouchDBClient(account: account, username: username, password: password)

/*: 
 
 ## Databases
 
 Accessing documents from cloudant can be achieved through the `Database` struct. To get a database call `CouchDBClient.database` or
 construct the struct directly.
*/
let db =  client.database("test")
/*:
 
 ### Creating a Database
 
 To create the database on the server, call `create()` it will throw an error if the database exists or could not be created. Each database function
 will return a tuple of the response and `HTTPInfo` struct which contrains HTTP information such as response code and headers.
 
 - important: HTTP status codes need to be checked whenever an operation which writes data to the server is used. For example
 with cloudant if write quorum is not met, a 202 is returned rather than a 201. This means that some nodes of the cluster may not
 have the data that has just been written. Applications need to be written to be aware of eventual consistency.
 
*/
let httpInfo = try db.create()

if httpInfo.statusCode == 201 {
    print("DB created succesfully")
} else if httpInfo.statusCode == 202 {
    print("DB Creation request accepted, it may take some time to complete")
}
/*:
 
 ### Deleting a Database.
 
 To delete a datbase the `delete` method is called on the `Database` struct.
 
 - Note: The struct will still be usable after `delete` has been called, however if you wish to interact with 
 the datanase again the `create` method will need to be called.
 
 
 - Example: In the code below, we are using the defer statement to delete the database when the page completes, this so data is cleaned up.
   In general applications the delete function should be called like:
 
    ` do {`\
    ` let deleteResponse = try db.delete()`\
    `} catch {`\
    `    // handle error`\
    ` }`
 
 */
defer { try? db.delete() }
/*:
 
 ## Acessing Data
 
 ### Creating a Document
 
 Saving a document to Cloudant is straight forward, pass the document in its entirity to the `database.save` method which will create or update
 a document on the server depending on the content of the document. Omitting the `_id` field will cause CouchDB / Cloudant to generate an 
 ID for you.
 
 - example:  Using CouchDB / Cloudant to generate document IDs.
 
    ` let (response, _ ) = try db.save(document: ["hello":"world"])` \
    `let generated = response["_id"] as! String`
 
 - important: A document cannot have fields with an `_` prefix for user data. `_` prefixed fields are for meta data **only** and any documents
   which contain `_` prefixed fields which are not meta data will be rejected by the server.
 */
let (response, _) = try db.save(document: ["_id": "test", "hello":"world"])

/*:
 
 ### Reading a Document
 
 Retriving a document from the server is again straight forward. All is required is the ID of the document
 to fetch from the database. The doc property below is the full document (exlcuding attachments) at the current 
 "winning" revision.
 
 - Note: It is possible to get a document without knowing it's ID. It is covered later in [bulk](Bulk) section of the playground.
 */
var (doc, _) = try db.get(document: "test")

//: ### Updating a Document
//: To update a document you call save with the modified document, it **must** contain the _id and _rev fields for the document to 
//: be updated successfully.
//: - Note: If the `_rev` field is missing, the operation will generate a conflict error on the server.
//: If `_id` is missing a new document with a generated ID will be created.

doc["foo"] = "bar"
let (updated, _) = try db.save(document: doc)

//: ### Deleting a Document.
//: To delete a document from the database only the id and revision of the document is required. Any "leaf" revision can be deleted from
//: the database.
//: - callout("Leaf" Revisions): A leaf revision is a revision which is revision which does not have an ancestor revision.
let deleteResponse = try db.delete(document: updated["id"] as! String, revision: updated["rev"] as! String)



//: Next: [Bulk Operations](@next)
































