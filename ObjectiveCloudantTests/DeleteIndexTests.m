//
//  DeleteIndexTests.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 06/10/2015.
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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "TestHelpers.h"

@interface DeleteIndexTests : XCTestCase
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) CDTDatabase *database;

@end

@implementation DeleteIndexTests

- (void)setUp
{
    [super setUp];

    self.url = @"http://localhost:5984";
    self.username = nil;
    self.password = nil;

    // These tests require their own database as they modify content; create one

    self.dbName = [NSString stringWithFormat:@"%@-test-database-%@", REMOTE_DB_PREFIX,
                                             [TestHelpers generateRandomString:5]];

    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];
    self.database = client[self.dbName];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void)testDeleteIndexFailsNoDDocName
{
    XCTestExpectation *deleteIndex = [self expectationWithDescription:@"delete index"];
    CDTDeleteQueryIndexOperation *op = [[CDTDeleteQueryIndexOperation alloc] init];
    op.indexName = @"foo";
    op.indexType = CDTQueryIndexTypeJson;
    op.deleteIndexCompletionBlock = ^(NSInteger statusCode, NSError *error) {
      [deleteIndex fulfill];
      XCTAssertEqual(kCDTNoHTTPStatus, statusCode);
      XCTAssertNotNil(error);
    };

    [self.database addOperation:op];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectations failed");
                                 }];
}

- (void)testDeleteIndexFailsNoIndexName
{
    XCTestExpectation *deleteIndex = [self expectationWithDescription:@"delete index"];
    CDTDeleteQueryIndexOperation *op = [[CDTDeleteQueryIndexOperation alloc] init];
    op.desginDocName = @"foo";
    op.indexType = CDTQIndexTypeJson;
    op.deleteIndexCompletionBlock = ^(NSInteger statusCode, NSError *error) {
      [deleteIndex fulfill];
      XCTAssertEqual(kCDTNoHTTPStatus, statusCode);
      XCTAssertNotNil(error);
    };

    [self.database addOperation:op];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectations failed");
                                 }];
}

- (void)testDeleteIndex4xxError
{
    [OHHTTPStubs removeAllStubs];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return YES;
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
          return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:403 headers:@{}];
        }];

    XCTestExpectation *deleteIndex = [self expectationWithDescription:@"delete index"];
    CDTDeleteQueryIndexOperation *op = [[CDTDeleteQueryIndexOperation alloc] init];
    op.desginDocName = @"foo";
    op.indexName = @"bar";
    op.indexType = CDTQIndexTypeJson;
    op.deleteIndexCompletionBlock = ^(NSInteger statusCode, NSError *error) {
      [deleteIndex fulfill];
      XCTAssertEqual(4, statusCode / 100);
      XCTAssertNotNil(error);
    };

    [self.database addOperation:op];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectations failed");
                                 }];
}

- (void)testDeleteIndex5xxError
{
    [OHHTTPStubs removeAllStubs];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return YES;
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
          return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:500 headers:@{}];
        }];

    XCTestExpectation *deleteIndex = [self expectationWithDescription:@"delete index"];
    CDTDeleteQueryIndexOperation *op = [[CDTDeleteQueryIndexOperation alloc] init];
    op.desginDocName = @"foo";
    op.indexName = @"bar";
    op.indexType = CDTQIndexTypeJson;
    op.deleteIndexCompletionBlock = ^(NSInteger statusCode, NSError *error) {
      [deleteIndex fulfill];
      XCTAssertEqual(5, statusCode / 100);
      XCTAssertNotNil(error);
    };

    [self.database addOperation:op];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectations failed");
                                 }];
}

- (void)testDeleteIndex
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return [request.URL.path containsString:@"_index"];
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {

          if ([request.HTTPMethod isEqualToString:@"DELETE"]) {
              return [OHHTTPStubsResponse responseWithJSONObject:@{
                  @"ok" : @(YES)
              }
                                                      statusCode:200
                                                         headers:@{}];
          } else {
              // for this test we needed a delete throw a 405
              return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:405 headers:@{}];
          }
        }];

    XCTestExpectation *deleteIndex = [self expectationWithDescription:@"delete index"];
    CDTDeleteQueryIndexOperation *op = [[CDTDeleteQueryIndexOperation alloc] init];
    op.desginDocName = @"foo";
    op.indexName = @"bar";
    op.indexType = CDTQIndexTypeJson;
    op.deleteIndexCompletionBlock = ^(NSInteger statusCode, NSError *error) {
      [deleteIndex fulfill];
      XCTAssertEqual(200, statusCode);
      XCTAssertNil(error);
    };

    [self.database addOperation:op];

    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectations failed");
                                 }];
}

@end
