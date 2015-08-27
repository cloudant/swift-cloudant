//
//  CDTCouchOperation.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "CDTCouchOperation.h"

@implementation CDTCouchOperation

#pragma mark Sub-class overrides

- (void)buildAndValidate
{
    return;
}

- (void)main
{
    [self buildAndValidate];
}

#pragma mark HTTP methods

- (void)executeJSONRequestWithMethod:(NSString*)method
                                path:(NSString*)path
                   completionHandler:(void (^)(NSObject *result, NSURLResponse *res, NSError *error))completionHandler
{
    [self executeRequestWithMethod:method
                              path:path
                 completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                     if (err) {
                         completionHandler(nil, res, err);
                     } else {
                         NSObject *result = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:nil];
                         completionHandler(result, res, nil);
                     }
                 }];
}

- (void)executeRequestWithMethod:(NSString*)method
                            path:(NSString*)path
               completionHandler:(void (^)(NSData *result, NSURLResponse *res, NSError *error))completionHandler
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.rootURL 
                                              resolvingAgainstBaseURL:NO];
    
    components.path = path;
    components.queryItems = components.queryItems ? components.queryItems : @[];
    components.queryItems = [components.queryItems arrayByAddingObjectsFromArray:self.queryItems];
    
    NSLog(@"%@", [[components URL] absoluteString]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request setHTTPMethod:method];
    //    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                                                     completionHandler(data, res, err);
                                                 }];
    [task resume];
}

@end
