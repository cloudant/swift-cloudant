//
//  CDTInterceptableSession.m
//
//  Created by Rhys Short.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CDTInterceptableSession.h"

@interface CDTInterceptableSession ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSArray *interceptors;

@end

@implementation CDTInterceptableSession

- (instancetype)init { return [self initWithDelegate:nil requestInterceptors:@[]]; }
- (instancetype)initWithDelegate:(NSObject<NSURLSessionDelegate> *)delegate
             requestInterceptors:(NSArray *)requestInterceptors;
{
    self = [super init];
    if (self) {
        _interceptors = [NSArray arrayWithArray:requestInterceptors];

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session =
            [NSURLSession sessionWithConfiguration:config delegate:delegate delegateQueue:nil];
    }
    return self;
}

- (void)dealloc { [self.session finishTasksAndInvalidate]; }
- (CDTURLSessionTask *)dataTaskWithRequest:(NSURLRequest *)request
                         completionHandler:(void (^)(NSData *data, NSURLResponse *response,
                                                     NSError *error))completionHandler
{
    CDTURLSessionTask *task = [[CDTURLSessionTask alloc] initWithSession:self.session
                                                                 request:request
                                                            interceptors:self.interceptors];
    __weak CDTInterceptableSession *weakSelf = self;
    task.completionHandler =
        ^void(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
          __strong CDTInterceptableSession *strongSelf = weakSelf;
          if (strongSelf && completionHandler) {
              data = [NSData dataWithData:data];
              completionHandler(data, response, error);
          }
        };
    return task;
}

@end
