//
//  POAPIClient.m
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "POAPIClient.h"

@implementation POAPIClient

static NSString *const kMeetupAPIBaseURLString = @"https://api.meetup.com/2/";

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (POAPIClient *)sharedClient
{
    static POAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kMeetupAPIBaseURLString]];
    });
    
    return _sharedClient;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Accept-Charset" value:@"utf-8"];
    
    return self;
}

@end
