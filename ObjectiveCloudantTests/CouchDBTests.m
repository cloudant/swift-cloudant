//
//  CouchDBTests.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 02/10/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ObjectiveCloudant/ObjectiveCloudant.h>

@interface CDTCouchDBClient ()

@property NSString* username;
@property NSString* password;
@property NSURL* rootURL;

@end

@interface CouchDBTests : XCTestCase

@end

@implementation CouchDBTests

- (void)testUserInfoIsRemovedFromURL
{
    NSURL* baseURL = [NSURL URLWithString:@"https://example.cloudant.com"];
    NSString* username = @"user";
    NSString* password = @"password";

    NSURLComponents* components =
        [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:NO];
    components.user = username;
    components.password = password;

    CDTCouchDBClient* client =
        [CDTCouchDBClient clientForURL:components.URL username:nil password:nil];

    XCTAssertEqualObjects(username, client.username);
    XCTAssertEqualObjects(password, client.password);
    XCTAssertEqualObjects(baseURL, client.rootURL);
}

@end
