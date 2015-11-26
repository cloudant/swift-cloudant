//
//  CDTOperationRequestExecutor.h
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

#import <Foundation/Foundation.h>

#import "CDTOperationRequestExecutorDelegate.h"

@class CDTCouchOperation;

/**
 The executor handles the boilerplate of making a request
 and doing initial processing of the response. It calls back
 into the operation for operation-specific items.
 
 Broadly the order of operations is:
 
 1. Create a request using CDTOperationRequestBuilder and the operation.
 2. Execute the request asynchronously.
 3. On receiving the response:
 1. Check whether the operation is cancelled; if so, call `-completeOperation`
 on the operation, then return early.
 2. Call `-processResponseWithData:statusCode:error:` on the operation.
 3. Call `-completeOperation` on the operation.
 4. Return.
 
 The idea is to remove the necessity of calling completeOperation, checking for cancellation,
 retrieving the status code and so on from the operations themselves.
 
 */
@interface CDTOperationRequestExecutor : NSObject

/**
 Initialise with the operation to make a request for.
 */
- (instancetype)initWithOperation:(NSOperation<CDTOperationRequestExecutorDelegate> *)operation;

/**
 Execute the request async, and callback into the operation as described above.
 
 After calling executeRequest, the operation need not retain the executor.
 */
- (void)executeRequest;

@end
