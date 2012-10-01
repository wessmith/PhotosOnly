//
//  POFetchManager.h
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POFetchManager : NSObject

/*
 * The maximum number of results in each response [default = 20].
 */
@property (nonatomic) NSInteger pageSize;

/*
 * The starting page for results to return [default = 0].
 */
@property (nonatomic) NSInteger offset;

/*
 * A threshold (0.0 -> 1.0) determining how precisely the fetch should adhere to the page size [default = 0.8].
 *
 * Example: With a page size of 20, the fetch returns 15 results with the criteria that you want.
 *          If the threshold is set to 0.9, the fetch would not have satisfied the criteria and would
 *          fetch another page of results.
 */
@property (nonatomic) float threshold;

/*
 * Indicates whether the threshold was satisfied in the last fetch.
 */
@property (nonatomic, readonly) BOOL thresholdSatisfied;

/*
 * The number of matching results on the server.
 */
@property (nonatomic) NSInteger totalMatchingResults;

/*
 * The number of results remaining matching the criteria.
 */
@property (nonatomic, readonly) NSInteger remainingResults;

/*
 * Indicates whether the manager is currently fetching.
 */
@property (nonatomic, getter = isFetching) BOOL fetching;

/*
 * Indicates that there are no more results matching the criteria.
 */
@property (nonatomic, readonly) BOOL hasReachedEnd;

/*
 * Set an attribute key to be used in filtering the results.
 */
- (void)setKeyForRequiredAttribute:(NSString *)requiredAttributeKey;

/*
 * Returns results that contain a value for the required attribute.
 */
- (NSArray *)filteredResultsWithArray:(NSArray *)unfilteredResults;

@end
