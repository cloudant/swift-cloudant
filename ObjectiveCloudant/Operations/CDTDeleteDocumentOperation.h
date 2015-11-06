//
//  CDTDeleteDocumentOperation.h
//  ObjectiveCloudant
//
//  Created by Rhys Short on 21/09/2015.
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
 An operation to delete documents from the database.
 */
@interface CDTDeleteDocumentOperation : CDTCouchDatabaseOperation

/**
 The document that this operation will delete.

 Must be set before a call can be successfully made.
 */
@property (nullable, nonatomic, strong) NSString *docId;

/**
 The current revision ID of the document to be deleted.

 Must be set before a call can be succesfully made.
 */
@property (nullable, nonatomic, strong) NSString *revId;

/**
 * Completion block to run when the operation completes.
 *
 * status - the status code from the HTTP request, if a request hasn't been made
 * it will be set to the value of kCDTNoHTTPStatus
 * operationError - a pointer to an error object containing information about an error executing
 * this operation.
 **/
@property (nullable, nonatomic, copy) void (^deleteDocumentCompletionBlock)
    (NSInteger statusCode, NSError *_Nullable operationError);

@end
