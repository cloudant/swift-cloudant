//
//  CDTCreateQueryIndexOperation.h
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

#import <ObjectiveCloudant/ObjectiveCloudant.h>

@interface CDTCreateQueryIndexOperation : CDTCouchDatabaseOperation

/**
 * The name of the index.
 * Optional: CouchDb will automatically generate an index name
 * if its not set.
 **/
@property (nullable, nonatomic, strong) NSString* indexName;

/**
 *  The fields to be included in the index.
 *  Required: Needs to be set with a non zero length array.
 **/
@property (nullable, nonatomic, strong) NSArray<NSObject*>* fields;

/**
 * The index type to use, deafults to json.
 **/
@property (nonatomic) CDTQueryIndexType indexType;

/**
 * The name of the design doc this index should be included with
 * Optional: CouchDB will automatically generate a deisgn doc
 * for this index.
 **/
@property (nullable, nonatomic, strong) NSString* designDocName;

/**
 * Completion block to run when the operation completes
 *
 * operationError - a pointer to an error object containing information about an error executing
 * this operation.
 **/
@property (nullable, nonatomic, strong) void (^createIndexCompletionBlock)
    (NSError* _Nullable operationError);

@end
