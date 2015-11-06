//
//  CDTQueryFindDocumentsOperation.h
//  ObjectiveCloudant
//
//  Created by Rhys Short on 07/10/2015.
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
 An operation to find documents using Query.
 */
@interface CDTQueryFindDocumentsOperation : CDTCouchDatabaseOperation

/**
 * The selector for the query. See
 * [the Cloudant documentation](https://docs.cloudant.com/cloudant_query.html#selector-syntax)
 * for syntax information.
 *
 * Required: This needs to be set before the operation can successfully run.
 **/
@property (nullable, nonatomic, strong) NSDictionary<NSString*, NSObject*>* selector;

/**
 * The fields to include in the results.
 *
 * Optional: Default is null
 **/
@property (nullable, nonatomic, strong) NSArray<NSString*>* fields;

/**
 * The number maximium number of documents to return.
 *
 * Optional: The database will choose a limit, negative values will
 * result in the parameter not being included in requests
 **/
@property (nonatomic) NSInteger limit;

/**
 * Skip the first _n_ results, where _n_ is specified by skip.
 *
 * Optional: The database will choose a number of documents to skip,
 * negative values will result in the parameter not being included in
 * requests
 **/
@property (nonatomic) NSInteger skip;

/**
 * How to sort the results, the array must follow sort syntax as documented in
 * [the Cloudant documentation](https://docs.cloudant.com/cloudant_query.html#sort-syntax)
 *
 * Optional: The database will decide how sort results.
 **/
@property (nullable, nonatomic, strong) NSArray* sort;

/**
 * A string that enables you to specify which page of results you require.
 *
 * Optional: The database will return the first page without this set.
 *
 * Note: This is only for valid text indexes.
 **/
@property (nullable, nonatomic, strong) NSString* bookmark;

/**
 * A specific index to run the query against.
 *
 * Optional: The Database will determine the index to run the query
 * against if omitted.
 **/
@property (nullable, nonatomic, strong) NSString* useIndex;

/**
 * The read quorum for this request.
 *
 * Optional: The Database will determine the read quorum, negative values will
 * result in the parameter not being included in requests.
 *
 * WARNING: This is an advanced option and is rarely, if ever, needed. It will be detrimental to
 *performance.
 *
 **/
@property (nonatomic) NSInteger r;

/**
 * Block to run for each document retrived from the database matching the query.
 *
 * - document - a document matching the query.
 **/
@property (nullable, nonatomic, strong) void (^documentFoundBlock)
    (NSDictionary<NSString*, NSObject*>* _Nonnull document);

/**
 Completion block to run when the operation completes.

 - bookmark - the results of the query. See
 [the Cloudant documentation](https://docs.cloudant.com/cloudant_query.html#finding-documents-using-an-index)
 for details
 - operationError - a pointer to an error object containing
 information about an error executing the operation
 **/
@property (nullable, nonatomic, strong) void (^findDocumentsCompletionBlock)
    (NSString* _Nullable bookmark, NSError* _Nullable error);
@end
