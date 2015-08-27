//
//  Database.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CouchDB;
@class CDTGetDocumentOperation;

@interface Database : NSObject

- (instancetype)initWithClient:(CouchDB*)client databaseName:(NSString*)name;

- (NSDictionary*)objectForKeyedSubscript:(NSString*)key;

- (NSDictionary*)getDocumentWithOperation:(void (^)(CDTGetDocumentOperation *b))callback;


@end
