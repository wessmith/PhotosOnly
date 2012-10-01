//
//  Group.h
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *photoURL;
@property (nonatomic, strong) NSNumber *members;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)groupsWithBlock:(void (^)(NSArray *groups, NSError *error))block;

@end
