//
//  DeleteDocumentTests.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 21/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestHelpers.h"
#import <ObjectiveCloudant/ObjectiveCloudant.h>

@interface DeleteDocumentTests : XCTestCase

@property NSString *url;
@property NSString *username;
@property NSString *password;
@property NSString *dbName;
@property CouchDB *client;
@property CDTDatabase *db;

@end

@implementation DeleteDocumentTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the
    // class.

    self.url = @"http://localhost:5984";
    self.username = nil;
    self.password = nil;

    // These tests require their own database as they modify content; create one

    self.dbName = [NSString stringWithFormat:@"%@-test-database-%@", REMOTE_DB_PREFIX,
                                             [TestHelpers generateRandomString:5]];

    self.client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                               username:self.username
                               password:self.password];

    CDTCreateDatabaseOperation *createDB = [[CDTCreateDatabaseOperation alloc] init];
    createDB.databaseName = self.dbName;
    [self.client addOperation:createDB];
    [createDB waitUntilFinished];

    self.db = self.client[self.dbName];
}

- (void)tearDown
{
    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    CDTDeleteDatabaseOperation *delete = [[CDTDeleteDatabaseOperation alloc] init];
    delete.databaseName = self.dbName;
    [client addOperation:delete];
    [delete waitUntilFinished];

    [super tearDown];
}

- (void)testDocmentCanBeDeleted
{
    NSString *docId = @"deleteDocumentTest";

    // make a document
    CDTPutDocumentOperation *put = [[CDTPutDocumentOperation alloc] init];
    put.docId = docId;
    put.body = @{ @"Hello" : @"World" };

    __block NSString *revId = nil;

    put.putDocumentCompletionBlock =
        ^(NSInteger statusCode, NSString *docId, NSString *revid, NSError *erorr) {
          revId = revid;
        };
    [self.db addOperation:put];
    [put waitUntilFinished];

    // now Do the delete stuff
    CDTDeleteDocumentOperation *delete = [[CDTDeleteDocumentOperation alloc] init];
    delete.docId = docId;
    delete.revId = revId;

    __block NSError *error = nil;

    delete.deleteDocumentCompletionBlock = ^(NSInteger statusCode, NSError *inError) {
      error = inError;
    };
    [self.db addOperation:delete];
    [delete waitUntilFinished];
    XCTAssertNil(error);

    // get the document we should have deleted.
    CDTGetDocumentOperation *get = [[CDTGetDocumentOperation alloc] init];
    get.docId = docId;

    __block NSDictionary *document = nil;
    get.getDocumentCompletionBlock = ^(NSDictionary *_Nullable innerDocument, NSError *error) {
      document = innerDocument;
    };
    [self.db addOperation:get];
    [get waitUntilFinished];

    XCTAssertNil(document);
}

- (void)testDocumentcanBeDeletedViaConvienence
{
    NSString *docId = @"deleteDocumentTest";

    CDTPutDocumentOperation *put = [[CDTPutDocumentOperation alloc] init];
    put.docId = docId;
    put.body = @{ @"Hello" : @"World" };

    __block NSString *revId = nil;

    put.putDocumentCompletionBlock =
        ^(NSInteger statusCode, NSString *docId, NSString *revid, NSError *error) {
          revId = revid;
        };

    [self.db addOperation:put];
    [put waitUntilFinished];

    XCTestExpectation *deleteExpectation =
        [self expectationWithDescription:@"Delete Document from DB"];
    XCTestExpectation *getDeletedDocument =
        [self expectationWithDescription:@"Get deleted document from db"];

    [self.db deleteDocumentWithId:docId
                       revisionId:revId
              completetionHandler:^(NSInteger statusCode, NSError *_Nullable error) {
                XCTAssertNil(error);
                XCTAssertEqual(
                    statusCode / 100,
                    2);  // 2xx = ok, allows for clustering acceptance, next block may not fail.
                [deleteExpectation fulfill];

                // get the document from the server,
                [self.db getDocumentWithId:docId
                         completionHandler:^(NSDictionary *_Nullable document,
                                             NSError *_Nullable error) {
                           XCTAssertNil(document);
                           XCTAssertNil(error);
                           [getDeletedDocument fulfill];
                         }];

              }];
    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed to delete document from DB");
                                 }];
}

- (void)testDeleteDocumentOpFailsValidationConvience
{
    XCTestExpectation *deleteExpectation =
        [self expectationWithDescription:@"Delete Document from DB"];
    // deliberately passing nil to fail validation
    [self.db deleteDocumentWithId:nil
                       revisionId:@""
              completetionHandler:^(NSInteger statusCode, NSError *_Nullable error) {
                XCTAssertNotNil(error);
                XCTAssertEqual(statusCode, kCDTNoHTTPStatus);
                [deleteExpectation fulfill];

              }];
    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed to delete document from DB");
                                 }];
}

- (void)testDeleteDocumentOpFailsValidation
{
    XCTestExpectation *deleteExpectation =
        [self expectationWithDescription:@"Delete Document from DB"];
    CDTDeleteDocumentOperation *delete = [[CDTDeleteDocumentOperation alloc] init];
    delete.revId = @"";

    delete.deleteDocumentCompletionBlock = ^(NSInteger statusCode, NSError *inError) {
      XCTAssertNotNil(inError);
      XCTAssertEqual(statusCode, kCDTNoHTTPStatus);
      [deleteExpectation fulfill];
    };

    [self.db addOperation:delete];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed to delete document from DB");
                                 }];
}

- (void)testDeleteDocumentOpFailsValidationConvienceNoRevId
{
    XCTestExpectation *deleteExpectation =
        [self expectationWithDescription:@"Delete Document from DB"];
    // delibratly passing nil to fail validation
    [self.db deleteDocumentWithId:@"docId"
                       revisionId:nil
              completetionHandler:^(NSInteger statusCode, NSError *_Nullable error) {
                XCTAssertNotNil(error);
                XCTAssertEqual(statusCode, kCDTNoHTTPStatus);
                [deleteExpectation fulfill];

              }];
    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed to delete document from DB");
                                 }];
}

- (void)testDeleteDocumentOpFailsValidationNoRevId
{
    XCTestExpectation *deleteExpectation =
        [self expectationWithDescription:@"Delete Document from DB"];
    CDTDeleteDocumentOperation *delete = [[CDTDeleteDocumentOperation alloc] init];
    delete.docId = @"docId";

    delete.deleteDocumentCompletionBlock = ^(NSInteger statusCode, NSError *inError) {
      XCTAssertNotNil(inError);
      XCTAssertEqual(statusCode, kCDTNoHTTPStatus);
      [deleteExpectation fulfill];
    };

    [self.db addOperation:delete];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed to delete document from DB");
                                 }];
}

- (void)testDocumentDeleteFailsWrongRev
{
    NSString *docId = @"deleteDocumentTest";

    CDTPutDocumentOperation *put = [[CDTPutDocumentOperation alloc] init];
    put.docId = docId;
    put.body = @{ @"Hello" : @"World" };

    __block NSString *revId = nil;

    put.putDocumentCompletionBlock =
        ^(NSInteger statusCode, NSString *docId, NSString *revid, NSError *error) {
          revId = revid;
        };

    [self.db addOperation:put];
    [put waitUntilFinished];

    put = [[CDTPutDocumentOperation alloc] init];
    put.docId = docId;
    put.revId = revId;
    put.body = @{ @"Hello" : @"World", @"Updated" : @(YES) };
    // don't use a completion block, we don't care about the result really.

    [self.db addOperation:put];
    [put waitUntilFinished];

    XCTestExpectation *deleteExpectation =
        [self expectationWithDescription:@"Delete Document from DB"];
    XCTestExpectation *getDeletedDocument =
        [self expectationWithDescription:@"Get deleted document from db"];

    [self.db deleteDocumentWithId:docId
                       revisionId:revId
              completetionHandler:^(NSInteger statusCode, NSError *_Nullable error) {
                XCTAssertNotNil(error);
                XCTAssertEqual(statusCode, 409);  // should be a conflict.
                [deleteExpectation fulfill];

                // get the document from the server, making sure it still exists on the server
                [self.db getDocumentWithId:docId
                         completionHandler:^(NSDictionary *_Nullable document,
                                             NSError *_Nullable error) {
                           XCTAssertNotNil(document);
                           XCTAssertNil(error);
                           [getDeletedDocument fulfill];
                         }];

              }];
    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed to delete document from DB");
                                 }];
}

@end
