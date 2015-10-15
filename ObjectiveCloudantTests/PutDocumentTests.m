//
//  PutDocumentTests.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
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

@interface PutDocumentTests : XCTestCase

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation PutDocumentTests

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

    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    CDTCreateDatabaseOperation *create = [[CDTCreateDatabaseOperation alloc] init];
    create.databaseName = self.dbName;
    [client addOperation:create];
    [create waitUntilFinished];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.

    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    CDTDeleteDatabaseOperation *delete = [[CDTDeleteDatabaseOperation alloc] init];
    delete.databaseName = self.dbName;
    [client addOperation:delete];
    [delete waitUntilFinished];

    [super tearDown];
}

- (void)testPutDocumentCreate
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    NSString *docId = @"doc-testPutDocument";

    CDTDatabase *database = client[self.dbName];

    CDTPutDocumentOperation *put = [[CDTPutDocumentOperation alloc] init];
    put.docId = docId;
    put.body = @{ @"hello" : @"world" };
    [database addOperation:put];
    [put waitUntilFinished];

    __block NSDictionary *retrievedDoc;
    CDTGetDocumentOperation *get = [[CDTGetDocumentOperation alloc] init];
    get.docId = docId;
    get.getDocumentCompletionBlock = ^(NSDictionary *doc, NSError *err) { retrievedDoc = doc; };
    [database addOperation:get];
    [get waitUntilFinished];

    XCTAssertEqual(3, retrievedDoc.count);
    XCTAssertEqualObjects(docId, retrievedDoc[@"_id"]);
    XCTAssertEqualObjects(@"world", retrievedDoc[@"hello"]);

    NSLog(@"document: %@", retrievedDoc);
}

- (void)testPutDocumentUpdate
{
    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
                                                     username:self.username
                                                     password:self.password];

    NSString *docId = @"doc-testPutDocument";

    CDTDatabase *database = client[self.dbName];

    __block NSString *createdRevId;

    CDTPutDocumentOperation *put = [[CDTPutDocumentOperation alloc] init];
    put.docId = docId;
    put.body = @{ @"hello" : @"world" };
    put.putDocumentCompletionBlock =
        ^(NSString *docId, NSString *revId, NSInteger statusCode, NSError *err) {
          createdRevId = revId;
        };
    [database addOperation:put];
    [put waitUntilFinished];

    XCTAssertNotNil(createdRevId);

    put = [[CDTPutDocumentOperation alloc] init];
    put.docId = docId;
    put.revId = createdRevId;
    put.body = @{ @"foo" : @"bar" };
    [database addOperation:put];
    [put waitUntilFinished];

    __block NSDictionary *retrievedDoc;
    CDTGetDocumentOperation *get = [[CDTGetDocumentOperation alloc] init];
    get.docId = docId;
    get.getDocumentCompletionBlock = ^(NSDictionary *doc, NSError *err) { retrievedDoc = doc; };
    [database addOperation:get];
    [get waitUntilFinished];

    XCTAssertEqual(3, retrievedDoc.count);
    XCTAssertEqualObjects(docId, retrievedDoc[@"_id"]);
    XCTAssertEqualObjects(nil, retrievedDoc[@"hello"]);
    XCTAssertEqualObjects(@"bar", retrievedDoc[@"foo"]);

    NSLog(@"document: %@", retrievedDoc);
}

@end
