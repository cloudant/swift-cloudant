//
//  ObjectiveCouchTests.m
//  ObjectiveCouchTests
//
//  Created by Michael Rhodes on 15/08/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import <XCTest/XCTest.h>

#import <ObjectiveCloudant/ObjectiveCloudant.h>
#import "TestHelpers.h"

@interface ObjectiveCouchTests : XCTestCase

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation ObjectiveCouchTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the
    // class.

    self.url = @"http://localhost:5984";
    self.username = nil;
    self.password = nil;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
    [super tearDown];
}

- (void)testCreateCloudantClient
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    NSString *expected = [NSString stringWithFormat:@"[url: %@]", self.url];
    XCTAssertEqualObjects(expected, [client description]);
}

- (void)testGetDatabase
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    CDTDatabase *database = client[@"objectivecouch-test"];

    NSString *expected =
        [NSString stringWithFormat:@"[database: objectivecouch-test; client: [url: %@]]", self.url];
    XCTAssertEqualObjects(expected, [database description]);
}

- (void)testGetDocument
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    CDTDatabase *database = client[@"objectivecouch-test"];

    NSDictionary *document = database[@"aardvark"];

    XCTAssertEqual(10, document.count);
    XCTAssertEqualObjects(@"aardvark", document[@"_id"]);
    XCTAssertEqualObjects(@1, document[@"min_length"]);

    NSLog(@"document: %@", document);
}

- (void)testGetDocumentWithEmptyOptions
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    CDTDatabase *database = client[@"objectivecouch-test"];

    __block NSDictionary *document;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [database getDocumentWithId:@"aardvark"
              completionHandler:^(NSDictionary *doc, NSError *err) {
                  document = doc;
                  dispatch_semaphore_signal(sema);
              }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));

    XCTAssertEqual(10, document.count);
    XCTAssertEqualObjects(@"aardvark", document[@"_id"]);
    XCTAssertEqualObjects(@1, document[@"min_length"]);

    NSLog(@"document: %@", document);
}

- (void)testGetDocumentWithIncludeRevs
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    CDTDatabase *database = client[@"objectivecouch-test"];

    __block NSDictionary *document;

    CDTGetDocumentOperation *op = [[CDTGetDocumentOperation alloc] init];
    op.docId = @"aardvark";
    op.revs = YES;
    op.getDocumentCompletionBlock = ^(NSDictionary *doc, NSError *err) { document = doc; };
    [database addOperation:op];
    [op waitUntilFinished];

    XCTAssertEqual(11, document.count);
    XCTAssertEqualObjects(@"aardvark", document[@"_id"]);
    XCTAssertEqualObjects(@1, document[@"min_length"]);
    XCTAssertNotNil(document[@"_revisions"]);

    NSLog(@"document: %@", document);
}

- (void)testGetDocumentAtSpecifiedRevision
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    XCTestExpectation *createDB = [self expectationWithDescription:@"create db"];

    __block NSString *revision;
    CDTCreateDatabaseOperation *dbOp = [[CDTCreateDatabaseOperation alloc] init];
    dbOp.databaseName =
        [NSString stringWithFormat:@"objective-cloudant-%@", [TestHelpers generateRandomString:5]];
    dbOp.createDatabaseCompletionBlock =
        ^(NSInteger statusCode, NSError *_Nullable operationError) {
          [createDB fulfill];
          XCTAssertNil(operationError);
        };
    [client addOperation:dbOp];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   if (error) NSLog(@"Failed to create DB");
                                 }];

    XCTestExpectation *firstRevCreate = [self expectationWithDescription:@"Create inital revision"];

    CDTDatabase *database = client[dbOp.databaseName];

    [database putDocumentWithId:@"doc1"
                           body:@{
                               @"Hello" : @"World"
                           }
              completionHandler:^(NSString *_Nullable docId, NSString *_Nullable revId,
                                  NSInteger statusCode, NSError *_Nullable operationError) {
                [firstRevCreate fulfill];
                XCTAssertNil(operationError);
                revision = revId;
              }];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   if (error) NSLog(@"Failed to create document");
                                 }];

    XCTestExpectation *secondRevCreate =
        [self expectationWithDescription:@"Create second revision"];

    [database putDocumentWithId:@"doc1"
                     revisionId:revision
                           body:@{
                               @"Hello" : @"World",
                               @"Updated" : @(YES)
                           }
              completionHandler:^(NSString *_Nullable docId, NSString *_Nullable revId,
                                  NSInteger statusCode, NSError *_Nullable operationError) {
                [secondRevCreate fulfill];
                XCTAssertNil(operationError);
              }];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   if (error) NSLog(@"Failed to update document");
                                 }];

    XCTestExpectation *getRevWithRevId = [self expectationWithDescription:@"Get inital revision"];

    [database getDocumentWithId:@"doc1"
                     revisionId:revision
              completionHandler:^(NSDictionary<NSString *, NSObject *> *_Nullable document,
                                  NSError *_Nullable operationError) {
                [getRevWithRevId fulfill];
                XCTAssertNil(operationError);
                XCTAssertNil(document[@"Updated"]);
                XCTAssertEqualObjects(revision, document[@"_rev"]);
              }];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   if (error)
                                       NSLog(@"Failed to get document with specified revision");
                                 }];
}

@end
