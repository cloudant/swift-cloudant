//
//  CouchDBTests.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 02/10/2015.
//  Copyright (c) IBM Corp. 2015
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
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
