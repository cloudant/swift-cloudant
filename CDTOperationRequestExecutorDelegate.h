//
//  CDTOperationRequestBuilderDelegate.h
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 24/11/2015.
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

#import <Foundation/Foundation.h>

#import "CDTOperationRequestBuilderDelegate.h"

@class CDTInterceptableSession;

/**
 Contains the methods required for using an NSOperation with CDTOperationRequestBuilder.
 */
@protocol CDTOperationRequestExecutorDelegate <CDTOperationRequestBuilderDelegate>

/**
 Returns the session used to make HTTP requests.
 */
- (nonnull CDTInterceptableSession *)session;

/**
 Should execute necessary NSOperation completion KVO work.
 */
- (void)completeOperation;

@optional

/**
 This callback should do operation-specific processing of the
 request content. It need not worry about NSOperation lifecycle.
 
 It doesn't need to check whether the operation was cancelled, or
 call the CDTCouchOperation completion handler, that's handled
 by the caller of this method.
 */
- (void)processResponseWithData:(nullable NSData *)responseData
                     statusCode:(NSInteger)statusCode
                          error:(nullable NSError *)error;


@end
