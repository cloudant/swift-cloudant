//
//  CreateDatabaseTests.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ObjectiveCloudant/ObjectiveCloudant.h>

#import "TestHelpers.h"

@interface CreateDatabaseTests : XCTestCase

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation CreateDatabaseTests

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
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.

    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    __block NSError *error;

    CDTDeleteDatabaseOperation *delete = [[CDTDeleteDatabaseOperation alloc] init];
    delete.databaseName = self.dbName;
    delete.deleteDatabaseCompletionBlock = ^(NSError *err) { error = err; };
    [client addOperation:delete];
    [delete waitUntilFinished];

    XCTAssertNil(error);

    [super tearDown];
}

- (void)testCreateUsingPut
{
    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    __block NSInteger statusCode;

    CDTCreateDatabaseOperation *op = [[CDTCreateDatabaseOperation alloc] init];
    op.databaseName = self.dbName;
    op.createDatabaseCompletionBlock = ^(NSInteger sc, NSError *err) { statusCode = sc; };
    [client addOperation:op];
    [op waitUntilFinished];

    XCTAssertTrue((statusCode == 201 || statusCode == 202));
}

@end
