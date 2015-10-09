//
//  TCLAPIClient.h
//  TCL
//
//  Created by Mamun on 9/20/14.
//  Copyright (c) 2014 ABCoder. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AppAPIClient : AFHTTPSessionManager
+ (instancetype)sharedClient;

@end
