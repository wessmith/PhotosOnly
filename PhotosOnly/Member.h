//
//  Member.h
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POFetchManager;

@interface Member : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *photoURL;

- (id)initWithAttributes:(NSDictionary *)attributes;


+ (void)membersInGroup:(NSString *)groupID withFetchManager:(POFetchManager *)fetchManager completion:(void (^)(BOOL doneFetching, NSArray *members, NSError *error))completion;

//+ (void)membersInGroup:(NSString *)groupID withBlock:(void (^)(NSArray *members, NSError *error))block;

@end
