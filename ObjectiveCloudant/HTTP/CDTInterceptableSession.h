//
//  CDTInterceptableSession.h
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

#import <Foundation/Foundation.h>
#import "CDTURLSessionTask.h"

@class CDTHTTPInterceptorContext;

/**
 Façade class to NSURLSession, enabling requests and responses to be modified.
 */

@interface CDTInterceptableSession : NSObject

/**
 * Initalises A CDTInterceptableSession without a delegate and an empty array of interceptors.
 **/
- (instancetype)init;

/**
 * Initalise a CDTInterceptableSession.
 *
 * @param delegate An object that implements NSURLSessionDelegate protocol
 * @param requestInterceptors Array of interceptors that should be run before each request is made.
 **/
- (instancetype)initWithDelegate:(NSObject<NSURLSessionDelegate> *)delegate
             requestInterceptors:(NSArray *)requestInterceptors NS_DESIGNATED_INITIALIZER;

/**
 * Performs a data task for a request.
 *
 * @param request The request to make
 * @param completionHandler A block to call when the request completes
 *
 * @return returns a task to used the make the request. `resume` needs to be called
 * in order for the task to start making the request.
 */
- (CDTURLSessionTask *)dataTaskWithRequest:(NSURLRequest *)request
                         completionHandler:(void (^)(NSData *data, NSURLResponse *response,
                                                     NSError *error))completionHandler;

@end
