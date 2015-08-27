//
//  Cloudant.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CouchDB.h"
#import "CDTCouchOperation.h"

#import "Database.h"

@interface CouchDB ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSOperationQueue *queue;

/**
 Root URL for the CouchDB instance.
 */
@property (nonatomic, strong) NSURL *rootURL;

@end

@implementation CouchDB

+ (CouchDB *)clientForURL:(NSURL *)url username:(NSString *)username password:(NSString *)password
{
    return [[CouchDB alloc] initForURL:url username:username password:password];
}

- (instancetype)initForURL:(NSURL *)url username:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (self) {
        _rootURL = url;
        _username = username;
        _password = password;
        _queue = [[NSOperationQueue alloc] init];

        NSURLSessionConfiguration *sessionConfiguration =
            [NSURLSessionConfiguration defaultSessionConfiguration];
        if (self.username && self.password) {
            NSString *creds = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
            NSString *b64 =
                [[creds dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
            NSString *header = [NSString stringWithFormat:@"Basic %@", b64];
            sessionConfiguration.HTTPAdditionalHeaders = @{ @"Authorization" : header };
        }
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return self;
}

- (Database *)objectForKeyedSubscript:(NSString *)key
{
    return [[Database alloc] initWithClient:self databaseName:key];
}

- (NSString *)description { return [NSString stringWithFormat:@"[url: %@]", self.rootURL]; }

- (void)addOperation:(CDTCouchOperation *)operation
{
    operation.session = self.session;
    operation.rootURL = self.rootURL;
    operation.username = self.username;
    operation.password = self.password;
    [self.queue addOperation:operation];
}

@end
