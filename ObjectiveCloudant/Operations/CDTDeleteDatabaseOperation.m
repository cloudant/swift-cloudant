//
//  CDTDeleteDatabaseOperation.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "CDTDeleteDatabaseOperation.h"

@interface CDTDeleteDatabaseOperation ()

@property (nullable, nonatomic, strong) CDTURLSessionTask *task;

@end

@implementation CDTDeleteDatabaseOperation

- (void)buildAndValidate { [super buildAndValidate]; }

#pragma mark Instance methods

- (void)dispatchAsyncHttpRequest
{
    NSString *path = [NSString stringWithFormat:@"/%@", self.databaseName];

    NSURLComponents *components =
        [NSURLComponents componentsWithURL:self.rootURL resolvingAgainstBaseURL:NO];

    components.path = path;
    components.queryItems = components.queryItems ? components.queryItems : @[];
    components.queryItems = [components.queryItems arrayByAddingObjectsFromArray:self.queryItems];

    NSLog(@"%@", [[components URL] absoluteString]);

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[components URL]
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:10.0];

    [request setHTTPMethod:@"DELETE"];

    __weak CDTDeleteDatabaseOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable res,
                              NSError *_Nullable error) {
            CDTDeleteDatabaseOperation *self = weakSelf;

            if (error) {
                if (self && self.deleteDatabaseCompletionBlock) {
                    self.deleteDatabaseCompletionBlock(error);
                }
            } else {
                NSInteger statusCode = ((NSHTTPURLResponse *)res).statusCode;
                if (statusCode == 200) {
                    // Success
                    if (self && self.deleteDatabaseCompletionBlock) {
                        self.deleteDatabaseCompletionBlock(nil);
                    }
                } else {
                    NSString *json =
                        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString *msg =
                        [NSString stringWithFormat:@"Database creation failed with %ld %@.",
                                                   statusCode, json];
                    NSDictionary *userInfo =
                        @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                    NSError *error =
                        [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorDeleteDatabaseFailed
                                        userInfo:userInfo];
                    if (self && self.deleteDatabaseCompletionBlock) {
                        self.deleteDatabaseCompletionBlock(error);
                    }
                }
            }

            [self completeOperation];
          }];
    [self.task resume];
}

@end
