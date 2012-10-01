# PhotosOnly

This demo project illustrates a method of fetching representations from an API where the API does not have a way to filter the results by the desired attribute.

In this particular example, the Meetup API does not have a way to fetch just the members with photos. Instead, we have to just fetch the members and filter them after receiving the results. 
This poses a problem: Say there are 100 members in a group. If we fetch the first 20 members and only 5 have photos, we're going to end up with only 5 members and likely  not filled up the tableview. That leaves the user with no indication that there are more members to be loaded (and removes the ability to trigger a fetch when scrolling to the bottom). How do we know ot fetch more? How do we know that we havent filled the table?

While the best solution here is most likely to add the ability to filter by members with photos in the API method, this example shows a possible workaround (though not necessarily elegant, it can work in a pinch). 

## The Gist
The way this demo works is by introducing a fetch manager class that keeps track of the state of the request and evaluates the filtered results against a threshold that determines whether or not another fetch should be made to satisfy the orginal request.

Basically, the tableViewController creates and "retains" a fetch manager with the appropriate settings:
````objective-c

// Hang on to the fetch manager in your tableViewController.
self.fetchManager = [[POFetchManager alloc] init];
fetchManager.pageSize = 20;
self.fetchManager.threshold = 0.8; //We'll accept 16 with photos

````

The fetchManager is passed to a class method on the model class `Member` that is responsible for fetching from the API. The implementation of that method can then use the fetchManager to determine if it needs to fetch another page of results to satisfy the request. Here is the example implementation using AFNetworking for the network requests:
````objective-c

+ (void)membersInGroup:(NSString *)groupID withFetchManager:(POFetchManager *)fetchManager completion:(void (^)(BOOL doneFetching, NSArray *members, NSError *error))completion
{   
    if (fetchManager.isFetching) return;
    
    fetchManager.fetching = YES;
    
    // Parameters for the request.
    NSDictionary *params = @{
        @"group_id" : groupID,
        @"page" : @(fetchManager.pageSize),
        @"offset" : @(fetchManager.offset),
        @"key" : @"YOUR_API_KEY"
    };
    
    // The results must contain this attribute to be counted.
    [fetchManager setKeyForRequiredAttribute:@"photo.thumb_link"];
    
    POAPIClient *client = [POAPIClient sharedClient];
    
    // FAILURE BLOCK.
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Fetching error: \n%@", error);
        
        if (completion) completion(YES, nil, error);
    };
    
    // SUCCESS BLOCK.
    void (^__block successBlock)(AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Increment the offset.
        fetchManager.offset++;
        
        // The fetchManager will calculate the remaining results
        // once the total matching results are set.
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
            
            // Update the parameters with the new offset.
            NSMutableDictionary *mutableParams = [params mutableCopy];
            [mutableParams setValue:@(fetchManager.offset) forKey:@"offset"];
            
            // Do another fetch...
            [client getPath:@"members" parameters:mutableParams success:successBlock failure:failureBlock];
            
        } else {
            
            fetchManager.fetching = NO;
            
            // Update the caller with the current results.
            completion(YES, members, nil);
        }
    };
    
    
    // Start the fetching...
    if (!fetchManager.hasReachedEnd) {
    
        [client getPath:@"members" parameters:params success:successBlock failure:failureBlock];
    } else {
        
        fetchManager.fetching = NO;
        completion(YES, [NSArray array], nil);
    }
}

````
