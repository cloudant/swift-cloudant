//
//  CDTGetDocumentOperation.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "CDTCouchOperation.h"

@interface CDTGetDocumentOperation : CDTCouchOperation

@property (nonatomic) bool revs;
@property (nonatomic, strong) NSString *docId;
@property (nonatomic, strong) NSString *databaseName;

@property(nonatomic, copy) void (^getDocumentCompletionBlock)( NSDictionary *document, NSError *operationError);

@end
