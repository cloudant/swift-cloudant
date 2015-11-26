//
//  CDTOperationRequestBuilder.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 21/11/2015.
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

#import "CDTOperationRequestBuilder.h"

#import "CDTCouchOperation.h"
#import "CDTOperationRequestBuilderDelegate.h"

@interface CDTOperationRequestBuilder ()

@property (nonatomic, strong) NSURL *rootURL;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSArray *queryItems;
@property (nonatomic, strong) NSData *body;

@end

@implementation CDTOperationRequestBuilder

- (nullable instancetype)initWithOperation:
    (nonnull NSOperation<CDTOperationRequestBuilderDelegate> *)operation;
{
    self = [super init];
    if (self) {
        // Required parts of CDTOperationRequestBuilderDelegate
        _method = operation.httpMethod;
        _rootURL = operation.rootURL;
        _path = operation.httpPath;

        // Optional parts of CDTOperationRequestBuilderDelegate
        if ([operation respondsToSelector:@selector(queryItems)]) {
            _queryItems = operation.queryItems;
        }
        if ([operation respondsToSelector:@selector(httpRequestBody)]) {
            _body = operation.httpRequestBody;
        }
    }
    return self;
}

- (nonnull NSURLRequest *)buildRequest;
{
    NSURLComponents *components =
        [NSURLComponents componentsWithURL:self.rootURL resolvingAgainstBaseURL:NO];

    components.path = self.path;
    components.queryItems = components.queryItems ? components.queryItems : @[];
    components.queryItems = [components.queryItems arrayByAddingObjectsFromArray:self.queryItems];

    NSLog(@"%@", [[components URL] absoluteString]);

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[components URL]
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:10.0];

    [request setHTTPMethod:self.method];

    if (self.body) {
        request.HTTPBody = self.body;
    }

    return request;
}

@end
