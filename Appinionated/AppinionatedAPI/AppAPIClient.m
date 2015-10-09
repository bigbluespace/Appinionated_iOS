//
//  TCLAPIClient.m
//  TCL
//
//  Created by Mamun on 9/20/14.
//  Copyright (c) 2014 ABCoder. All rights reserved.
//

#import "AppAPIClient.h"

static NSString * const AppAPIBaseURLString = @"http://appinionated-custom.appinstitute.co.uk/";//@"http://appinionated-development.appinstitute.co.uk/";
//static NSString * const AppAPIBaseURLString = @"http://app-development.appinstitute.co.uk/";

@implementation AppAPIClient

+ (instancetype)sharedClient {
    static AppAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AppAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AppAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        // ************ VERY VERY IMPORTANT for API *******************
        _sharedClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];     
    });
    return _sharedClient;
}
@end
