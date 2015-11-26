//
//  CDTCouchOperation.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
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

#import "CDTCouchOperation.h"
#import "CDTCouchOperation+internal.h"
#import "CDTOperationRequestExecutor.h"

NSString *const CDTObjectiveCloudantErrorDomain = @"CDTObjectiveCloudantErrorDomain";
NSInteger const kCDTNoHTTPStatus = 0;

@interface CDTCouchOperation ()

@property (nullable, nonatomic, strong) CDTURLSessionTask *task;

@end

@implementation CDTCouchOperation

#pragma mark Sub-class overrides

- (BOOL)buildAndValidate { return YES; }

- (void)dispatchAsyncHttpRequest { return; }

- (void)callCompletionHandlerWithError:(NSError *)error { return; }

- (NSString *)httpPath { return @"/"; }

- (NSString *)httpMethod { return @"GET"; }

#pragma mark Concurrent operation NSOperation functions

- (id)init
{
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (BOOL)isConcurrent { return YES; }

- (BOOL)isExecuting { return executing; }

- (BOOL)isFinished { return finished; }
- (void)cancel
{
    [super cancel];
    [self.task cancel];
}

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    // Validate settings before starting execution
    if (![self buildAndValidate]) {
        NSString *msg = [NSString stringWithFormat:@"Validation of operation failed."];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
        NSError *error = [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                             code:CDTObjectiveCloudantErrorValidationFailed
                                         userInfo:userInfo];
        [self callCompletionHandlerWithError:error];

        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    //    [self dispatchAsyncHttpRequest];
    CDTOperationRequestExecutor *executor =
    [[CDTOperationRequestExecutor alloc] initWithOperation:self];
    [executor executeRequest];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    executing = NO;
    finished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
