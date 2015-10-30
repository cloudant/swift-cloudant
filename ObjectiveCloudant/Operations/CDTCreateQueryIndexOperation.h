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
 *
 *  For JSON Indexes, the syntax for specifying fields is Sort Syntax.
 *
 *  Example: `@[ @{ @"age": @"asc"} ]`
 *
 *  For Text indexes, you need to specify the data type for the field,
 *  only `string`, `number`, or `boolean` are accepted.
 *
 *  Example: `@[ @{ @"name": @"age", @"type", @"number"} ]"
 *
 *
 *  Required: fields are required for *JSON Indexes*
 *  Optional: fields are optional for *Text Indexes*
 *
 * @see https://docs.cloudant.com/cloudant_query.html#creating-an-index
 **/
@property (nullable, nonatomic, strong) NSArray<NSObject*>* fields;

/**
 * The name of the analyzer to use for $text operator with this index.
 * Optional: CouchDb will use the default analyzer if one is not specified
 * Note: text indexes only
 **/
@property (nullable, nonatomic, strong) NSString* defaultFieldAnalyzer;

/**
 * If the default field should be enabled for this index.
 *
 * If default field is disabled, the `$text` operator will
 * return 0 results. If you wish to use the `$text` operator
 * the index being created needs this option to be set to YES.
 *
 * Default: NO, default field index is disabled by default
 * Note: text indexes only
 */
@property (nonatomic) BOOL defaultFieldEnabled;

/**
 * A selector to limit the documents in the index.
 * Optional: If ommited all documents will be included in the index
 * Note: text indexes only.
 **/
@property (nullable, nonatomic, strong) NSDictionary* selector;

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
