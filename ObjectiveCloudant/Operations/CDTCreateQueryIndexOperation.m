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
#import "CDTSortSyntaxValidator.h"
#import "CDTCouchOperation+internal.h"

// Testing this class will need to mock the entire query back end,
// XCTest doesn't provide a way to skip tests based on conditions
@interface CDTCreateQueryIndexOperation ()

@property (nullable, nonatomic, strong) NSData *jsonBody;
@property NSURLRequest *request;

@end

@implementation CDTCreateQueryIndexOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _indexType = CDTQueryIndexTypeJson;
        _defaultFieldEnabled = NO;
    }
    return self;
}

- (BOOL)buildAndValidate
{
    if (![super buildAndValidate]) {
        return NO;
    }

    switch (self.indexType) {
        case CDTQueryIndexTypeJson:
            return [self buildAndValidateJsonIndex];
        case CDTQueryIndexTypeText:
            return [self buildAndValidateTextIndex];
        default:
            return NO;
    }
}

- (BOOL)buildAndValidateJsonIndex
{
    // Check whether any text index specific attributes are set; fail if they are
    if (self.selector) {
        return NO;
    }
    if (self.defaultFieldEnabled || self.defaultFieldAnalyzer) {
        return NO;
    }

    // fields is the only required parameter
    if ((!self.fields) || self.fields.count == 0) {
        return NO;
    } else {
        if (![CDTSortSyntaxValidator validateSortSyntaxInArray:self.fields]) {
            return NO;
        }
     }

    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"index"] = @{ @"fields" : self.fields };
    body[@"type"] = @"json";
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

- (BOOL)buildAndValidateTextIndex
{
    // fields parameter is not requried for text indexes
    if (self.fields.count > 0) {  // equal to zero will cause indexing everywhere
        // check the fields are a 2 element dict of strings
        for (NSObject *item in self.fields) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSDictionary *field = (NSDictionary *)item;
                if (field.count != 2) {
                    return NO;
                }

                NSObject *fieldName = field[@"name"];
                NSObject *type = field[@"type"];

                if (!fieldName || !type) {
                    return NO;
                }

                if (![fieldName isKindOfClass:[NSString class]]) {
                    return NO;
                }

                if (![@[ @"boolean", @"string", @"number" ] containsObject:type]) {
                    return NO;
                }
            } else {
                return NO;
            }
        }
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"index"] = [NSMutableDictionary dictionary];
    if (self.fields) {
        body[@"fields"] = self.fields;
    }
    body[@"type"] = @"text";
    if (self.defaultFieldEnabled) {
        // if default field is enabled, but an analyzer hasn't been set, don't emit any json for
        // default field, the user probably wants couchdb's defaults
        if (self.defaultFieldAnalyzer) {
            body[@"index"][@"default_field"] = @{
                @"enabled" : @(self.defaultFieldEnabled),
                @"analyzer" : self.defaultFieldAnalyzer
            };
        }
    } else {
        body[@"index"][@"default_field"] = @{ @"enabled" : @(self.defaultFieldEnabled) };
    }
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
        self.createIndexCompletionBlock(error);
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
                strongSelf.createIndexCompletionBlock(nil);
            } else if (error) {
                strongSelf.createIndexCompletionBlock(error);
            } else {
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *msg = [NSString
                    stringWithFormat:@"Index creation failed with %ld %@.", statusCode, json];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                error = [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorCreateQueryIndexFailed
                                        userInfo:userInfo];
                strongSelf.createIndexCompletionBlock(error);
            }

            [strongSelf completeOperation];

          }];
    [self.task resume];
}

@end
