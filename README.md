# swift-cloudant

**This is an experimental port of objective-cloudant into Swift. It is not supported.**

**Applications use swift-cloudant to store, index and query remote
JSON data on Cloudant or CouchDB.**

Swift-Cloudant is an [Apache CouchDB&trade;][acdb] client written in Swift 3. It
is built by [Cloudant](https://cloudant.com) and is available under the
[Apache 2.0 license][ap2].

[ap2]: https://github.com/cloudant/sync-android/blob/master/LICENSE
[acdb]: http://couchdb.apache.org/

## Early-Release

This is an early-release version of the library, with support for the following operations:

- Getting documents by doc ID.
- Updating and deleting documents.
- Creating and deleting databases.


We will be rounding out the feature set in upcoming releases.

**Currently it does not support being called from Objective-C.**

## Using in your project

SwiftCloudant is available using the Swift Package Manager and [CocoaPods](http://cocoapods.org).

To use with CocoaPods add the following line to your Podfile:

```ruby
pod SwiftCloudant, :git => 'https://github.com/cloudant/swift-cloudant.git'
```

To use with the swift package manager add the following line to your dependencies
in your Package.swift:
```swift
.Package(url: "https://github.com/cloudant/swift-cloudant.git")
```
## <a name="overview"></a>Overview of the library
```swift
import SwiftCloudant

// Create a CouchDBClient
let cloudantURL = NSURL(string:"https://username.cloudant.com")!
let client = CouchDBClient(url:cloudantURL, username:"username", password:"password")

// Access a database
let db = client["database"]

// Create a document
let create = PutDocumentOperation()
create.docId = "doc1"
create.body = ["hello":"world"]
create.completionHandler = {(response, httpInfo, error) in
    if let error = error {
        NSLog("Encountered an error while creating a document. Error:\(error)")
    } else {
        NSLog("Created document \(response?["id"]) with revision id \(response?["rev"])");
    }
}
db.add(operation:create)

// Read a document
let read = GetDocumentOperation()
read.docId = "doc1"
read.completionHandler = { (response, httpInfo, error) in
    if let error = error {
        NSLog("Encountered an error while reading a document. Error:\(error)";
    } else {
        NSLog("Read document: \(response)");
    }   
}
db.add(operation:read)

// Delete a document
let delete = DeleteDocumentOperation()
delete.docId = "doc1"
delete.revId = "1-revisionidhere"
delete.completionHandler = {(response, httpInfo, error) in
    if let error = error {
        NSLog("Encountered an error while deleting a document. Error: \(error)");
    } else {
        NSLog("Document deleted");
    }   
}
db.add(operation:delete)
```
## Requirements

Currently they are no third party dependencies.

## Contributors

See [CONTRIBUTORS](CONTRIBUTORS).

## Contributing to the project

See [CONTRIBUTING](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE)
