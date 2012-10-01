//
//  Member.m
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "Member.h"
#import "POAPIClient.h"
#import "POFetchManager.h"


@implementation Member

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self) return nil;
    
    _name = [attributes valueForKey:@"name"];
    _photoURL = [attributes valueForKeyPath:@"photo.thumb_link"];
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSArray *)membersFromRepresentations:(NSArray *)representations
{
    NSMutableArray *mutableMembers = [NSMutableArray arrayWithCapacity:representations.count];
    
    for (NSDictionary *representation in representations) {
        
        Member *member = [[Member alloc] initWithAttributes:representation];
        [mutableMembers addObject:member];
    }
    
    return mutableMembers;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)membersInGroup:(NSString *)groupID withFetchManager:(POFetchManager *)fetchManager completion:(void (^)(BOOL doneFetching, NSArray *members, NSError *error))completion
{
    NSAssert(completion != NULL, @"`membersInGroup:withFetchManager:completion:` -> completion block must not be NULL.");
    
    if (fetchManager.isFetching) return;
    
    fetchManager.fetching = YES;
    
    // Parameters for the request.
    NSDictionary *params = @{
        @"group_id" : groupID,
        @"page" : @(fetchManager.pageSize),
        @"offset" : @(fetchManager.offset),
        @"key" : kAPIKey
    };
    
    // The results must contain this attribute to be counted.
    [fetchManager setKeyForRequiredAttribute:@"photo.thumb_link"];
    
    POAPIClient *client = [POAPIClient sharedClient];
    
    // FAILURE BLOCK.
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Fetching error: \n%@", error);
        
        if (completion) {
            
            completion(YES, nil, error);
        }
    };
    
    // SUCCESS BLOCK.
    void (^__block successBlock)(AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Increment the offset.
        fetchManager.offset++;
        
        // Update the remaining results.
        NSDictionary *meta = [responseObject valueForKey:@"meta"];
        NSNumber *totalCount = [meta valueForKey:@"total_count"];
        fetchManager.totalMatchingResults = totalCount.integerValue;
        
        // Extract the results.
        NSArray *unfilteredResults = [responseObject valueForKey:@"results"];
        
        // Filter the results and convert them to Members.
        NSArray *filteredResults = [fetchManager filteredResultsWithArray:unfilteredResults];
        NSArray *members = [Member membersFromRepresentations:filteredResults];
        
        // If the threshold is not met, fetch more results.
        if (!fetchManager.thresholdSatisfied && fetchManager.remainingResults > 0) {

            // Update the caller with the current results.
            completion(NO, members, nil);
            
            // Update the parameters.
            NSMutableDictionary *mutableParams = [params mutableCopy];
            [mutableParams setValue:@(fetchManager.offset) forKey:@"offset"];
            
            NSLog(@"Fetching: %d -> %d ...", MAX(fetchManager.offset*fetchManager.pageSize, fetchManager.offset)+1, MAX((fetchManager.offset+1)*fetchManager.pageSize, fetchManager.pageSize));
            [client getPath:@"members" parameters:mutableParams success:successBlock failure:failureBlock];
            
        } else {
            
            fetchManager.fetching = NO;
            
            // Update the caller with the current results.
            completion(YES, members, nil);
        }
    };
    
    
    if (!fetchManager.hasReachedEnd) {
    
        NSLog(@"Fetching: %d -> %d ...", MAX(fetchManager.offset*fetchManager.pageSize, fetchManager.offset)+1, MAX((fetchManager.offset+1)*fetchManager.pageSize, fetchManager.pageSize));
        [client getPath:@"members" parameters:params success:successBlock failure:failureBlock];
    } else {
        
        fetchManager.fetching = NO;
        completion(YES, [NSArray array], nil);
    }
}

@end