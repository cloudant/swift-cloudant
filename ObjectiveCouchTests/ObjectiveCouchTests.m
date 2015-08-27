//
//  ObjectiveCouchTests.m
//  ObjectiveCouchTests
//
//  Created by Michael Rhodes on 15/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ObjectiveCouch/ObjectiveCouch.h>

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
    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    NSString *expected = [NSString stringWithFormat:@"[url: %@]", self.url];
    XCTAssertEqualObjects(expected, [client description]);
}

- (void)testGetDatabase
{
    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    Database *database = client[@"objectivecouch-test"];

    NSString *expected =
        [NSString stringWithFormat:@"[database: objectivecouch-test; client: [url: %@]]", self.url];
    XCTAssertEqualObjects(expected, [database description]);
}

- (void)testGetDocument
{
    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    Database *database = client[@"objectivecouch-test"];

    NSDictionary *document = database[@"aardvark"];

    XCTAssertEqual(10, document.count);
    XCTAssertEqualObjects(@"aardvark", document[@"_id"]);
    XCTAssertEqualObjects(@1, document[@"min_length"]);

    NSLog(@"document: %@", document);
}

- (void)testGetDocumentWithEmptyOptions
{
    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    Database *database = client[@"objectivecouch-test"];

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
    CouchDB *client = [CouchDB clientForURL:[NSURL URLWithString:self.url]
                                   username:self.username
                                   password:self.password];

    Database *database = client[@"objectivecouch-test"];

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

@end
