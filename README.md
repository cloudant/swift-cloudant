# swift-cloudant

[![codecov.io](https://codecov.io/github/rhyshort/swift-cloudant/coverage.svg?branch=master)](https://codecov.io/github/rhyshort/swift-cloudant?branch=master)

**This is an experimental port of objective-cloudant into Swift. It is not supported,
it is not tested, it may not even work.**

**Applications use swift-cloudant to store, index and query remote
JSON data on Cloudant or CouchDB.**

Objective-Cloudant is an [Apache CouchDB&trade;][acdb] client. It is built by
[Cloudant](https://cloudant.com) and is available under the [Apache 2.0 license][ap2].

[ap2]: https://github.com/cloudant/sync-android/blob/master/LICENSE
[acdb]: http://couchdb.apache.org/

## Early-Release

This is an early-release version of the library, with support for the following operations:

- Getting documents by doc ID.
- Updating and deleting documents.
- Creating Cloudant Query indexes (both JSON and text indexes).
- Finding documents via Cloudant Query.

We will be rounding out the feature set in upcoming releases.

## Using in your project

objective-cloudant is available through [CocoaPods](http://cocoapods.org), to install
it add the following line to your Podfile:

```ruby
pod ObjectiveCloudant
```

## <a name="overview"></a>Overview of the library

Once the library is added to a project the basics of adding and reading a document
are:

```objc
#import <ObjectiveCloudant/ObjectiveCloudant.h>

//Create a CDTCouchDBClient
NSURL *cloudantURL = [NSURL URLWithString:@"https://username.cloudant.com"];
CDTCouchDBClient *client = [CDTCouchDBClient clientForUrl:cloudantURL
                                                 username:@"username"
                                                 password:@"password"];

//access database
CDTDatabase *db = client[@"databasename"];

//create a document
[db putDocumentWithId:@"doc1"
                 body:@{@"hello":@"world"}
     completionHander:^(NSString *docId,
                        NSString *revId,
                        NSInteger statusCode,
                        NSError *operationError){
        if (operationError){
            NSLog(@"Error encountered while creating a document. Error: %@", error);
        } else {
            NSLog(@"Created document %@ with revision id %@", docId, revId);
        }

}];

//read a document
[db getDocumentWithId:@"doc1"
     completionHander:^(NSDictionary<NString*,NSObject*> *document,
                       NSError *operationError){
        if (operationError) {
            NSLog(@"Encountered an error while reading a document. Error:%@", error);
        } else {
            NSLog(@"Read document: %@",document);
        }
}];

//delete a document
[db deleteDocumentWithId:@"doc1"
           revisionId: @"1-revisionidhere"
    completionHandler: ^(NSInteger statusCode, error){
        if (error) {
            NSLog(@"Encountered an error while deleting a document. Error: %@", error);
        } else {
            NSLog(@"Document deleted");
        }
}];

```
And in swift use is as follows:
```swift
import ObjectiveCloudant

// create a CDTCouchDBClient
let url = NSURL(string: "https://example.cloudant.com")!
let client = CDTCouchDBClient(forURL: url,
        username: "username",
        password: "password")!

//access database
let db = client["example"]!


// create document
db.putDocumentWithId("doc1",
    body: ["hello": "world"],
    completionHandler: { (docId, revId, statusCode, operationError) -> Void in
        if let error = operationError {
            print("Encountered an error creating document. Error: \(error)")
        } else {
            print("Created document \(docId), at revision \(revId)")
        }
})


//read document
db.getDocumentWithId("doc1",
    completionHander:(document, operationError) -> Void {
        if let error = operationError {
            println("Encountered an error reading a document. Error: \(error)")
        } else {
            println("Read document \(document!)")
        }
})

//delete document
db.deleteDocumentWithId("doc1",
    revisionId: "1-revisionidhere",
    completionHandler: { (statusCode, operationError) -> Void in
        if let error = operationError {
            print("Encountered error: \(error!)")
        } else {
            print("document deleted")
        }
})

```

### Finding Data

Objective-cloudant directly supports the [Cloudant Query API ](https://docs.cloudant.com/cloudant_query.html).

#### Create Indexes

```objc
// Create a JSON Index
CDTCreateQueryIndexOperation *op = [[CDTCreateQueryIndexOperation alloc] init];
op.indexType = CDTQueryIndexTypeJson;
op.fields = @[ @{@"foo":@"asc"}, @{@"bar" : @"desc"}]
op.createIndexCompletionBlock = ^(NSError * _Nullable error){
       if(error){
           NSLog(@"Index creation failed. Error %@",error);
       } else {
           NSLog(@"Index created");
       }
   };

[db addOperation:op];


// Create a text index
CDTCreateQueryIndexOperation *op = [[CDTCreateQueryIndexOperation alloc] init];
op.indexType = CDTQueryIndexTypeText;
op.fields = @[ @{ @"name" : @"foo", @"type" : @"string"}]
op.createIndexCompletionBlock = ^(NSError * _Nullable error){
       if(error){
           NSLog(@"Index creation failed. Error %@",error);
       } else {
           NSLog(@"Index created");
       }
   };

[db addOperation:op];

```

```swift
// Create a JSON index
let op = CDTCreateQueryIndexOperation()
op.indexType = .Json
op.fields = [["foo":"asc"],["bar":desc]]
op.createIndexCompletionBlock =  {(error) -> Void in
        if let _ = error {
            print("Index creation failed with error: \(error)")
        } else {
            print("Index created")
        }
}

db.addOperation(op)

// Create a text index
let op = CDTCreateQueryIndexOperation()
op.indexType = .Text
op.fields = [["name":"foo","type":"string"]]
op.createIndexCompletionBlock =  {(error) -> Void in
        if let _ = error {
            print("Index creation failed with error: \(error)")
        } else {
            print("Index created")
        }
}

db.addOperation(op)

```

#### Query for documents

```objc
CDTQueryFindDocumentsOperation *op = [[CDTQueryFindDocumentsOperation alloc] init];
op.selector = @{@"foo": @"bar"};
op.documentFoundBlock = ^(NSDictionary * _Nonnull document){
    NSLog(@"Found document %@",document);
};
op.findDocumentCompletionBlock = ^(NSString * _Nullable bookmark, NSError* _Nullable error){
    if(error){
        NSLog(@"Failed to query database for documents");
    } else {
        NSLog(@"Query completed");
    }
};

[db addOperation:op];
```

```swift
let op = CDTQueryFindDocumentsOperation()
op.selector = ["foo":"bar"]
op.documentFoundBlock = {(document) -> Void in
    print("Found document \(document)")
}
op.findDocumentCompletionBlock = {(bookmark, error) -> Void in
    if let _ = error {
        print("Failed to query database for documents")
    } else {
        print("Query completed")
    }
}

db.addOperation(op)

```

#### Deleting an index

```objc
// Delete a JSON index
CDTDeleteQueryIndex *op = [[CDTDeleteQueryIndex alloc] init];
op.indexType = CDTQueryIndexTypeJson;
op.indexName = @"example";
op.desginDocName = @"exampleDesignDoc";
op.deleteIndexCompletionBlock = ^(NSInteger status, NSError * _Nullable error){
    if (error) {
        NSLog(@"Failed to delete index");
    } else {
        NSLog(@"Index deleted");
    }
};

[db addOperation:op];

// Delete a text index
CDTDeleteQueryIndex *op = [[CDTDeleteQueryIndex alloc] init];
op.indexType = CDTQueryIndexTypeText;
op.indexName = @"example";
op.desginDocName = @"exampleDesignDoc";
op.deleteIndexCompletionBlock = ^(NSInteger status, NSError * _Nullable error){
    if (error) {
        NSLog(@"Failed to delete index");
    } else {
        NSLog(@"Index deleted");
    };

[db addOperation:op];

```
```swift
// Delete a JSON index
let op = CDTDeleteQueryIndex()
op.indexType = .Json
op.indexName = "example"
op.designDocumentName = "exampleDesignDoc"
op.deleteIndexCompletionBlock = {(status, error) -> Void in
      if let _ = error {
          print("Failed to delete index")
      } else {
          print("Index deleted")
      }
}

db.addOperation(op)

// Delete a text index
let op = CDTDeleteQueryIndex()
op.indexType = .Text
op.indexName = "example"
op.designDocumentName = "exampleDesignDoc"
op.deleteIndexCompletionBlock = {(status, error) -> Void in
      if let _ = error {
          print("Failed to delete index")
      } else {
          print("Index deleted")
      }
}

db.addOperation(op)

```


## Requirements

Currently they are no third party dependancies

## Contributors

See [CONTRIBUTORS](CONTRIBUTORS).

## Contributing to the project

See [CONTRIBUTING](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE)
