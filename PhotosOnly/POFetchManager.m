//
//  POFetchManager.m
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "POFetchManager.h"
#import "POAPIClient.h"

@interface POFetchManager ()
@property (nonatomic, copy) NSString *requiredAttributeKey;
@property (nonatomic) NSInteger totalCombinedResults;
@end

@implementation POFetchManager

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    _pageSize = 20;
    _offset = 0;
    _threshold = 0.8;
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setKeyForRequiredAttribute:(NSString *)requiredAttributeKey
{
    self.requiredAttributeKey = requiredAttributeKey;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTotalMatchingResults:(NSInteger)totalMatchingResults
{
    if (_totalMatchingResults != totalMatchingResults) {
        _totalMatchingResults = totalMatchingResults;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)filteredResultsWithArray:(NSArray *)unfilteredResults
{
    NSMutableArray *filtered = [[NSMutableArray alloc] initWithCapacity:unfilteredResults.count];
    
    for (NSDictionary *representation in unfilteredResults) {
        
        // Check that the representation contains the required attribute.
        if ([representation valueForKeyPath:self.requiredAttributeKey] != nil) {
            
            [filtered addObject:representation];
        }
    }
    
    // Update the remaining results.
    _remainingResults = self.totalMatchingResults - (self.offset * self.pageSize);
    if (self.remainingResults < 1) {
        _remainingResults = 0;
        _hasReachedEnd = YES;
    }
    
    // Update the combined results.
    self.totalCombinedResults += filtered.count;
    
    // Set the flag to indicate if this satisfied the threshold.
    int minRequirement = self.pageSize * self.threshold;
    _thresholdSatisfied = (self.totalCombinedResults > minRequirement || self.remainingResults == 0);

    // Clear the counter if threshold is met.
    if (self.thresholdSatisfied) {
        
        NSLog(@"***************************************************");
        NSLog(@"Total filtered results: %d meets threshold of %d.", self.totalCombinedResults, minRequirement);
        NSLog(@"Satisfied request with total fetches: %d", (self.totalCombinedResults + self.pageSize -1)/self.pageSize);
        NSLog(@"Results remaining: %d", self.remainingResults);
        NSLog(@"***************************************************");
        
        self.totalCombinedResults = 0;
        
    } else {
        
        NSLog(@"Total filtered results: %d does not meet threshold of %d.", self.totalCombinedResults, minRequirement);
    }
    
    return filtered;
}

@end
