//
//  POAPIClient.h
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "AFHTTPClient.h"

static NSString *const kAPIKey = @"";
#error ENTER API KEY!!

@interface POAPIClient : AFHTTPClient

+ (POAPIClient *)sharedClient;

@end
