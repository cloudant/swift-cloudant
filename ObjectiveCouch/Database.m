//
//  Database.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "Database.h"

#import "CouchDB.h"
#import "CDTGetDocumentOperation.h"

@interface Database ()

@property (nonatomic, strong) CouchDB *client;
@property (nonatomic, strong) NSString *databaseName;

@end

@implementation Database

- (instancetype)initWithClient:(CouchDB *)client databaseName:(NSString *)name
{
    self = [super init];
    if (self) {
        _client = client;
        _databaseName = name;
    }
    return self;
}

- (NSString *)description
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

- (NSDictionary *)objectForKeyedSubscript:(NSString *)key
{
    __block NSDictionary *result;

    CDTGetDocumentOperation *op = [[CDTGetDocumentOperation alloc] init];
    op.docId = key;
    op.getDocumentCompletionBlock = ^(NSDictionary *doc, NSError *err) { result = doc; };
    [self addOperation:op];
    [op waitUntilFinished];

    return result;
}

#pragma mark Async convenience methods

- (void)getDocumentWithId:(NSString *)documentId
        completionHandler:(void (^)(NSDictionary *document, NSError *error))completionHandler
{
    CDTGetDocumentOperation *op = [[CDTGetDocumentOperation alloc] init];
    op.docId = documentId;
    op.getDocumentCompletionBlock = completionHandler;
    [self addOperation:op];
}

@end
