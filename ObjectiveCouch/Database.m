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

@property (nonatomic,strong) CouchDB *client;
@property (nonatomic,strong) NSString *databaseName;
@property (nonatomic,strong) NSURL *databaseURL;

@end

@implementation Database

- (instancetype)initWithClient:(CouchDB*)client databaseName:(NSString*)name
{
    self = [super init];
    if (self) {
        _client = client;
        _databaseName = name;
        _databaseURL = [NSURL URLWithString:name relativeToURL:client.rootURL];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[url: %@]", self.databaseURL.absoluteString];
}

- (NSDictionary*)objectForKeyedSubscript:(NSString*)key
{
    return [self getDocumentWithOperation:^(CDTGetDocumentOperation *o) {
        o.docId = key;
    }];
}

- (NSDictionary*)getDocumentWithOperation:(void (^)(CDTGetDocumentOperation *b))callback
{
    __block NSDictionary *result;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    CDTGetDocumentOperation *b = [[CDTGetDocumentOperation alloc] init];
    [self.client prepareOperation:b];
    b.databaseName = self.databaseName;
    if (callback) {
        callback(b);
    }
    b.getDocumentCompletionBlock = ^(NSDictionary *doc, NSError *err) {
        result = doc;
        dispatch_semaphore_signal(sema);
    };
    [b start];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    return result;
}

@end
