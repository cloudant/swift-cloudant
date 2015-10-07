//
//  CDTDatabase.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
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

#import "CDTDatabase.h"

#import "CDTCouchDBClient.h"
#import "CDTGetDocumentOperation.h"
#import "CDTDeleteDocumentOperation.h"
#import "CDTPutDocumentOperation.h"

@interface CDTDatabase ()

@property (nonnull, nonatomic, strong) CDTCouchDBClient *client;
@property (nonnull, nonatomic, strong) NSString *databaseName;

@end

@implementation CDTDatabase

- (nullable instancetype)initWithClient:(nonnull CDTCouchDBClient *)client
                           databaseName:(nonnull NSString *)name
{
    self = [super init];
    if (self) {
        _client = client;
        _databaseName = name;
    }
    return self;
}

- (nonnull NSString *)description
{
    return
        [NSString stringWithFormat:@"[database: %@; client: %@]", self.databaseName, self.client];
}

#pragma mark Operation management

- (void)addOperation:(CDTCouchDatabaseOperation *)operation
{
    operation.databaseName = self.databaseName;
    [self.client addOperation:operation];
}

#pragma mark Synchronous convenience accessors

- (nullable NSDictionary *)objectForKeyedSubscript:(nonnull NSString *)key
{
    __block NSDictionary *result;

    CDTGetDocumentOperation *op = [[CDTGetDocumentOperation alloc] init];
    op.docId = key;
    op.getDocumentCompletionBlock = ^(NSDictionary *doc, NSError *err) {
      result = doc;
    };
    [self addOperation:op];
    [op waitUntilFinished];

    return result;
}

#pragma mark Async convenience methods

- (void)getDocumentWithId:(nonnull NSString *)documentId
        completionHandler:(void (^_Nonnull)(NSDictionary *_Nullable document,
                                            NSError *_Nullable error))completionHandler
{
    CDTGetDocumentOperation *op = [[CDTGetDocumentOperation alloc] init];
    op.docId = documentId;
    op.getDocumentCompletionBlock = completionHandler;
    [self addOperation:op];
}

- (void)deleteDocumentWithId:(NSString *)documentId
                  revisionId:(NSString *)revId
         completetionHandler:(void (^)(NSInteger statusCode, NSError *_Nullable))completionHandler
{
    CDTDeleteDocumentOperation *op = [[CDTDeleteDocumentOperation alloc] init];
    op.docId = documentId;
    op.revId = revId;
    op.deleteDocumentCompletionBlock = completionHandler;
    [self addOperation:op];
}

- (void)putDocumentWithId:(NSString *)documentId
                     body:(NSDictionary *)body
        completionHandler:(void (^)(NSInteger, NSString *_Nullable, NSString *_Nullable,
                                    NSError *_Nullable))completionHandler
{
    CDTPutDocumentOperation *op = [[CDTPutDocumentOperation alloc] init];
    op.docId = documentId;
    op.body = body;
    op.putDocumentCompletionBlock = completionHandler;
    [self addOperation:op];
}

- (void)putDocumentWithId:(NSString *)documentId
               revisionId:(NSString *)revId
                     body:(NSDictionary *)body
        completionHandler:(void (^)(NSInteger, NSString *_Nullable, NSString *_Nullable,
                                    NSError *_Nullable))completionHandler
{
    CDTPutDocumentOperation *op = [[CDTPutDocumentOperation alloc] init];
    op.docId = documentId;
    op.revId = revId;
    op.body = body;
    op.putDocumentCompletionBlock = completionHandler;
    [self addOperation:op];
}

@end
