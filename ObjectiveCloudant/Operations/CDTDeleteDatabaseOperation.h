//
//  CDTDeleteDatabaseOperation.h
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import <ObjectiveCloudant/ObjectiveCloudant.h>

/**
 An operation to delete a database.
 */
@interface CDTDeleteDatabaseOperation : CDTCouchOperation

/**
 The name of the database to delete

 Required: This needs to be set before the operation can successfully run.
 */
@property (nullable, strong, nonatomic) NSString *databaseName;

/**
 Completion block to run when the operation completes.

 - statusCode - The status code of HTTP response, if the request
 hasn't been successfully made this will equal kCDTNoHTTPStatus
 - operationError - a pointer to an error object containing
 information about an error executing the operation
 */
@property (nonnull, nonatomic, copy) void (^deleteDatabaseCompletionBlock)
    (NSInteger statusCode, NSError *_Nullable operationError);

@end
