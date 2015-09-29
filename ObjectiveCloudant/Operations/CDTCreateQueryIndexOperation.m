//
//  CDTCreateQueryIndexOperation.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 22/09/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CDTCreateQueryIndexOperation.h"

// Testing this class will need to mock the entire query back end,
// XCTest doesn't provide a way to skip tests based on conditions
@interface CDTCreateQueryIndexOperation ()

@property (nullable, nonatomic, strong) NSData *jsonBody;
@property (nullable, nonatomic, strong) CDTURLSessionTask *task;
@property NSURLRequest *request;

@end

@implementation CDTCreateQueryIndexOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _indexType = CDTQIndexTypeJson;
    }
    return self;
}

- (BOOL)buildAndValidate
{
    if (![super buildAndValidate]) {
        return NO;
    }

    // fields is the only required parameter
    if ((!self.fields) || self.fields.count == 0) {
        return NO;
    } else {
        // check the fields are either string or 2 element dict of strings
        for (NSObject *item in self.fields) {
            if ([item isKindOfClass:[NSString class]]) {
                continue;
            } else if ([item isKindOfClass:[NSDictionary class]]) {
                // must be only one key, both strings.
                NSDictionary *sort = (NSDictionary *)item;
                if (sort.count != 1) {
                    return NO;
                }

                if (![sort.allKeys[0] isKindOfClass:[NSString class]]) {
                    return NO;
                }

                NSString *key = sort.allKeys[0];

                if (![sort[key] isKindOfClass:[NSString class]]) {
                    return NO;
                } else if (![sort[key] isEqualToString:@"asc"] &&
                           ![sort[key] isEqualToString:@"desc"]) {
                    return NO;
                }

            } else {
                return NO;
            }
        }
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"index"] = @{ @"fields" : self.fields };
    body[@"type"] = @"json";  // only type supported for now.
    if (self.indexName) {
        body[@"name"] = self.indexName;
    }
    if (self.designDocName) {
        body[@"ddoc"] = self.designDocName;
    }

    NSError *error = nil;

    self.jsonBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];

    return (self.jsonBody != nil);
}

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self.createIndexCompletionBlock) {
        self.createIndexCompletionBlock(kCDTNoHTTPStatus, error);
    }
}

- (void)dispatchAsyncHttpRequest
{
    NSString *path = [NSString stringWithFormat:@"/%@/_index", self.databaseName];

    NSURLComponents *components =
        [NSURLComponents componentsWithURL:self.rootURL resolvingAgainstBaseURL:NO];
    components.path = path;

    NSLog(@"%@", [[components URL] absoluteString]);

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:components.URL
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:10.0];
    request.HTTPMethod = @"POST";
    request.HTTPBody = self.jsonBody;

    self.request = request;

    __weak CDTCreateQueryIndexOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            CDTCreateQueryIndexOperation *strongSelf = weakSelf;

            // mark operation as complete and return if strongSelf is `nil`, OR
            // completionBlock is `nil` OR  the operation has been cancelled.
            if (!strongSelf || !strongSelf.createIndexCompletionBlock || [self isCancelled]) {
                [strongSelf completeOperation];
                return;
            }

            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (!error && data && statusCode / 100 == 2) {
                strongSelf.createIndexCompletionBlock(((NSHTTPURLResponse *)response).statusCode,
                                                      nil);
            } else if (error) {
                strongSelf.createIndexCompletionBlock(kCDTNoHTTPStatus, error);
            } else {
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *msg = [NSString
                    stringWithFormat:@"Index creation failed with %ld %@.", statusCode, json];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                error = [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorCreateDatabaseFailed
                                        userInfo:userInfo];
                strongSelf.createIndexCompletionBlock(statusCode, error);
            }

            [strongSelf completeOperation];

          }];
    [self.task resume];
}

@end
