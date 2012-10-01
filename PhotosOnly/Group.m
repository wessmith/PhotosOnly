//
//  Group.m
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "Group.h"
#import "POAPIClient.h"

@implementation Group

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self) return nil;
    
    _groupID = [NSString stringWithFormat:@"%@", [attributes valueForKey:@"id"]];
    _name = [attributes valueForKey:@"name"];
    _photoURL = [attributes valueForKeyPath:@"group_photo.thumb_link"];
    _members = [attributes valueForKey:@"members"];
    
    NSLog(@"Group ID = %@", _groupID);
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)groupsWithBlock:(void (^)(NSArray *groups, NSError *error))block
{
    POAPIClient *client = [POAPIClient sharedClient];
    
    NSDictionary *params = @{
        @"member_id" : @"self",
        @"key" : kAPIKey
    };
    
    [client getPath:@"groups" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *results = [responseObject valueForKey:@"results"];
        
        NSMutableArray *groups = [NSMutableArray arrayWithCapacity:results.count];
        
        for (NSDictionary *attributes in results) {
            
            Group *group = [[Group alloc] initWithAttributes:attributes];
            [groups addObject:group];
        }
        
     if (block) block(groups, nil);
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error fetching groups: \n%@", error);
        
        if (block) block(nil, error);
    }];
}

@end
