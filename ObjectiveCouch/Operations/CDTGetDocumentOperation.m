//
//  CDTGetDocumentOperation.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "CDTGetDocumentOperation.h"

@implementation CDTGetDocumentOperation

- (void)buildAndValidate
{
    [super buildAndValidate];

    self.queryItems =
        @[ [NSURLQueryItem queryItemWithName:@"revs" value:(self.revs ? @"true" : @"false")] ];
}

#pragma mark Instance methods

- (void)main
{
    [super main];

    NSString *path = [NSString stringWithFormat:@"/%@/%@", self.databaseName, self.docId];

    __block NSDictionary *result;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self executeJSONRequestWithMethod:@"GET"
                                  path:path
                     completionHandler:^(NSObject *json, NSURLResponse *res, NSError *err) {
                         if (!err) {
                             NSHTTPURLResponse *http = (NSHTTPURLResponse *)res;
                             if (http.statusCode == 200) {
                                 // We know this will be a dict
                                 result = (NSDictionary *)json;
                             }
                         }
                         dispatch_semaphore_signal(sema);
                     }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));

    if (self.getDocumentCompletionBlock) {
        self.getDocumentCompletionBlock(result, nil);
    }
}

@end
