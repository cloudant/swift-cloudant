//
//  CDTOperationRequestExecutor.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 21/11/2015.
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

#import "CDTOperationRequestExecutor.h"

#import "CDTCouchOperation.h"
#import "CDTOperationRequestBuilder.h"

@interface CDTOperationRequestExecutor ()

@property (nonatomic, strong) NSOperation<CDTOperationRequestExecutorDelegate> *operation;

/** Task is retained so the executor isn't deallocated before it's completed. */
@property (nullable, nonatomic, strong) CDTURLSessionTask *task;

@end

@implementation CDTOperationRequestExecutor

- (instancetype)initWithOperation:(NSOperation<CDTOperationRequestExecutorDelegate> *)operation;
{
    self = [super init];
    if (self) {
        _operation = operation;
    }
    return self;
}

- (void)executeRequest
{
    CDTOperationRequestBuilder *b =
    [[CDTOperationRequestBuilder alloc] initWithOperation:self.operation];
    NSURLRequest *request = [b buildRequest];
    
    // This is a retain loop. Self retains the task which retains the copied block which
    // retains self. We break the cycle when we set `self.task = nil` at the start of the
    // block. The loop is used to prevent the executor being deallocated before the task
    // is complete.
    self.task = [self.operation.session
                 dataTaskWithRequest:request
                 completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable res,
                                     NSError *_Nullable error) {
                     
                     // Break retain cycle (tested with breakpoint in a -dealloc for this class)
                     self.task = nil;
                     
                     if (!self) {
                         return;
                     }
                     
                     if ([self.operation isCancelled]) {
                         [self.operation completeOperation];
                         return;
                     }
                     
                     NSInteger statusCode = ((NSHTTPURLResponse *)res).statusCode;
                     
                     if ([self.operation respondsToSelector:@selector(processResponseWithData:statusCode:error:)]) {
                         [self.operation processResponseWithData:data statusCode:statusCode error:error];
                     }
                     
                     [self.operation completeOperation];
                 }];
    [self.task resume];
}

@end
