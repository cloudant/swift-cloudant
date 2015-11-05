//
//  CreateIndexTests.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 25/09/2015.
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
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import <ObjectiveCloudant/ObjectiveCloudant.h>
#import "TestHelpers.h"

@interface CreateIndexTests : XCTestCase
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) CDTDatabase *database;

@end

@implementation CreateIndexTests

- (void)setUp
{
    [super setUp];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return [request.URL.path containsString:@"_index"];
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
          return [OHHTTPStubsResponse responseWithJSONObject:@{
              @"ok" : @(YES)
          }
                                                  statusCode:200
                                                     headers:@{}];
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

- (void)testIndexCreation
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @"foo", @"bar" ];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationSortSyntaxAsc
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"foo" : @"asc" } ];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationSortSyntaxdesc
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"foo" : @"desc" } ];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationSortSyntaxDescAsec
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"foo" : @"desc" }, @{ @"bar" : @"asc" } ];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationSortSyntaxMixed
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"foo" : @"asc" }, @{ @"bar" : @"desc" }, @"hello" ];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithoutFields
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationValidationPassesWithoutOptionalValuesSet
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @"foo", @"bar" ];
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithEmptyArray
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[];
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithEmptyDictFields
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{} ];
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithDictKeyInt
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @(100) : @"World" } ];
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithDictValueNotExpected
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"Hello" : @"World" } ];
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreation5xxError
{
    [OHHTTPStubs removeAllStubs];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return [request.URL.path containsString:@"_index"];
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
          return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:500 headers:@{}];
        }];

    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @"foo", @"bar" ];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreation4xxError
{
    [OHHTTPStubs removeAllStubs];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
      return [request.URL.path containsString:@"_index"];
    }
        withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
          return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:400 headers:@{}];
        }];

    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @"foo", @"bar" ];
    index.indexName = @"foobarIndex";
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);
    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsUsingTextParamsWithJson
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @"foo", @"bar" ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldAnalyzer = @"spanish";
    index.defaultFieldEnabled = YES;
    index.indexType = CDTQueryIndexTypeJson;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsUsingSortSyntaxFields
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @"foo", @"bar" ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldAnalyzer = @"spanish";
    index.defaultFieldEnabled = YES;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationPassesWithNilfieldsTextIndex
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = nil;
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldAnalyzer = @"spanish";
    index.defaultFieldEnabled = YES;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationPassesWithDefaultFieldDisabled
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = nil;
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationPassesWithTextFieldSpecifiedTypeString
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"name" : @"day", @"type" : @"string" } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationPassesWithTextFieldSpecifiedTypeBoolean
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"name" : @"completed", @"type" : @"boolean" } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationPassesWithTextFieldSpecifiedTypeNumber
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"name" : @"year", @"type" : @"number" } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithTextFieldSpecifiedTypeText
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"name" : @"day", @"type" : @"text" } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithTextFieldSpecifiedInSortSyntax
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"day" : @"asc" } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithJSONFieldSpecifiedInTextSyntax
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"name" : @"day", @"type" : @"boolean" } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeJson;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithTextFieldSpecifiedWithTooManyKeys
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"name" : @"day", @"type" : @"boolean", @"oneTooMany" : @(YES) } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

- (void)testIndexCreationFailsWithTextFieldSpecifiedWithTooFewKeys
{
    CDTCreateQueryIndexOperation *index = [[CDTCreateQueryIndexOperation alloc] init];
    index.fields = @[ @{ @"name" : @"day" } ];
    index.selector = @{ @"foo" : @"bar" };
    index.defaultFieldEnabled = NO;
    index.indexType = CDTQueryIndexTypeText;
    XCTestExpectation *create = [self expectationWithDescription:@"Create index test"];
    index.createIndexCompletionBlock = ^(NSError *error) {
      [create fulfill];
      XCTAssertNotNil(error);

    };

    [self.database addOperation:index];

    [self waitForExpectationsWithTimeout:10
                                 handler:^(NSError *_Nullable error) {
                                   NSLog(@"Failed create index");
                                 }];
}

@end
