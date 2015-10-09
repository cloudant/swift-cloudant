//
//  FindDocumentTests.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 08/10/2015.
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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ObjectiveCloudant/ObjectiveCloudant.h>
#import "TestHelpers.h"

@interface FindDocumentTests : XCTestCase
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) CDTDatabase *database;
@end

@implementation FindDocumentTests

- (void)setUp
{
    [super setUp];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return [request.URL.path containsString:@"_find"] &&
             [request.HTTPMethod isEqualToString:@"POST"];
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
          return [OHHTTPStubsResponse responseWithJSONObject:@{
              @"docs" : @[
                  @{
                     @"_id" : @"2",
                     @"_rev" : @"1-9f0e70c7592b2e88c055c51afc2ec6fd",
                     @"foo" : @"test",
                     @"bar" : @(2600000)
                  },
                  @{
                     @"_id" : @"1",
                     @"_rev" : @"1-026418c17a353a9b73a6ccac19c142a4",
                     @"foo" : @"another test",
                     @"bar" : @(9800000)
                  }
              ]
          }
                                                  statusCode:200
                                                     headers:@{}];
        }];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return [request.URL.path containsString:@"_find"] &&
             ![request.HTTPMethod isEqualToString:@"POST"];
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
          return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:405 headers:@{}];
        }];

    self.url = @"http://localhost:5984";
    self.username = nil;
    self.password = nil;

    // These tests require their own database as they modify content; create one

    self.dbName = [NSString stringWithFormat:@"%@-test-database-%@", REMOTE_DB_PREFIX,
                                             [TestHelpers generateRandomString:5]];

    CDTCouchDBClient *client = [CDTCouchDBClient clientForURL:[NSURL URLWithString:self.url]
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

- (void)testInvalidSelector
{
    CDTQueryFindDocumentsOperation *op = [[CDTQueryFindDocumentsOperation alloc] init];
    op.selector = @{ @"foo" : op };

    XCTestExpectation *opExpect = [self expectationWithDescription:@"invalidSelector"];
    op.findDocumentsCompletionBlock = ^(NSString *_Nullable results, NSError *error) {
      [opExpect fulfill];
      XCTAssertNil(results);
      XCTAssertNotNil(error);
    };

    [self.database addOperation:op];
    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectation timed out");
                                 }];
}

- (void)testInvalidSortSyntaxFields
{
    CDTQueryFindDocumentsOperation *op = [[CDTQueryFindDocumentsOperation alloc] init];
    op.selector = @{ @"foo" : @"bar" };
    op.sort = @[ @{ @"foo" : @"bar" } ];

    XCTestExpectation *opExpect = [self expectationWithDescription:@"invalidSelector"];
    op.findDocumentsCompletionBlock = ^(NSString *_Nullable results, NSError *error) {
      [opExpect fulfill];
      XCTAssertNil(results);
      XCTAssertNotNil(error);
    };

    [self.database addOperation:op];
    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectation timed out");
                                 }];
}

- (void)testCanQueryDocsOnlySelector
{
    CDTQueryFindDocumentsOperation *op = [[CDTQueryFindDocumentsOperation alloc] init];
    op.selector = @{ @"foo" : @"bar" };

    XCTestExpectation *firstDoc = [self expectationWithDescription:@"1st doc result"];
    XCTestExpectation *secondDoc = [self expectationWithDescription:@"2nd doc result"];

    __block bool first = YES;

    op.documentFoundBlock = ^(NSDictionary<NSString *, NSObject *> *_Nonnull document) {
      if (first) {
          first = NO;
          [firstDoc fulfill];
      } else {
          [secondDoc fulfill];
      }

      XCTAssertNotNil(document);
      XCTAssertEqual(4, document.count);
    };

    XCTestExpectation *opExpect = [self expectationWithDescription:@"invalidSelector"];
    op.findDocumentsCompletionBlock = ^(NSString *_Nullable bookmark, NSError *error) {
      [opExpect fulfill];
      XCTAssertNil(bookmark);
      XCTAssertNil(error);
    };

    [self.database addOperation:op];
    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectation timed out");
                                 }];
}

- (void)testCanQueryDocsAllValuesSet
{
    CDTQueryFindDocumentsOperation *op = [[CDTQueryFindDocumentsOperation alloc] init];
    op.selector = @{ @"foo" : @"bar" };
    op.fields = @[ @"foo", @"bar" ];
    op.limit = 26;
    op.skip = 1;
    op.sort = @[ @"foo" ];
    op.bookmark = @"blah";
    op.useIndex = @"anIndex";

    XCTestExpectation *opExpect =
        [self expectationWithDescription:@"query docs, with all values set"];
    op.findDocumentsCompletionBlock = ^(NSString *bookmark, NSError *error) {
      [opExpect fulfill];
      XCTAssertNil(bookmark);
      XCTAssertNil(error);
    };

    [self.database addOperation:op];
    [self waitForExpectationsWithTimeout:10.0f
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Expectation timed out");
                                 }];
}

@end
