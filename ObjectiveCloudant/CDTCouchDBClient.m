//
//  CDTCouchDBClient.m
//  ObjectiveCouch
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
//

#import "CDTCouchDBClient.h"
#import "CDTCouchOperation.h"
#import "CDTInterceptableSession.h"
#import "CDTSessionCookieInterceptor.h"

#import "CDTDatabase.h"

@interface CDTCouchDBClient ()

@property (nullable, nonatomic, strong) NSString *username;
@property (nullable, nonatomic, strong) NSString *password;
@property (nullable, nonatomic, strong) CDTInterceptableSession *session;

@property (nonnull, nonatomic, strong) NSOperationQueue *queue;

/**
 Root URL for the CouchDB instance.
 */
@property (nullable, nonatomic, strong) NSURL *rootURL;

@end

@implementation CDTCouchDBClient

+ (nullable CDTCouchDBClient *)clientForURL:(nonnull NSURL *)url
                                   username:(nullable NSString *)username
                                   password:(nullable NSString *)password
{
    return [[CDTCouchDBClient alloc] initForURL:url username:username password:password];
}

- (nullable instancetype)initForURL:(nullable NSURL *)url
                           username:(nullable NSString *)username
                           password:(nullable NSString *)password
{
    self = [super init];
    if (self) {
        // If the URL contains a user info portion, strip them from the URL and enter into
        // the username and password class properties.
        if (url.user && url.password) {
            if (username || password) {
            NSLog(@"WARNING: Username and password provided in url, overriding username and "
                  @"password parameters");
            }
            NSURLComponents *components =
                [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            _username = components.user;
            components.user = nil;
            _password = components.password;
            components.password = nil;
            _rootURL = components.URL;

        } else {
            _rootURL = url;
            _username = username;
            _password = password;
        }
        _queue = [[NSOperationQueue alloc] init];

        NSMutableArray *interceptors = [NSMutableArray array];

        if (self.username && self.password) {
            [interceptors
                addObject:[[CDTSessionCookieInterceptor alloc] initWithUsername:self.username
                                                                       password:self.password]];
        }
        _session =
            [[CDTInterceptableSession alloc] initWithDelegate:nil requestInterceptors:interceptors];
    }
    return self;
}

- (nullable CDTDatabase *)objectForKeyedSubscript:(nonnull NSString *)key
{
    return [[CDTDatabase alloc] initWithClient:self databaseName:key];
}

- (nonnull NSString *)description { return [NSString stringWithFormat:@"[url: %@]", self.rootURL]; }
- (void)addOperation:(nonnull CDTCouchOperation *)operation
{
    operation.session = self.session;
    operation.rootURL = self.rootURL;
    [self.queue addOperation:operation];
}

@end
