//
//  CDTGetDocumentOperation.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CDTCouchDatabaseOperation.h"

@interface CDTGetDocumentOperation : CDTCouchDatabaseOperation

@property (nonatomic) bool revs;

/**
 The document that this operation will access or modify.

 Must be set before a call can be successfully made.
 */
@property (nonatomic, strong) NSString *docId;

@property (nonatomic, copy) void (^getDocumentCompletionBlock)
    (NSDictionary *document, NSError *operationError);

@end
