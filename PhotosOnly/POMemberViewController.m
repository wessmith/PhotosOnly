//
//  POMemberViewController.m
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "POMemberViewController.h"
#import "Member.h"
#import "Group.h"
#import "POFetchManager.h"

@interface POMemberViewController ()

@property (nonatomic, strong) POFetchManager *fetchManager;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation POMemberViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupFetchManager
{
    if (!self.fetchManager) {
        self.fetchManager = [[POFetchManager alloc] init];
        self.fetchManager.pageSize = 100;
        self.fetchManager.threshold = 0.9;
    }
    
    [self loadMembers];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadMembers
{
    [self.activityView startAnimating];
    
    [Member membersInGroup:self.group.groupID withFetchManager:self.fetchManager completion:^(BOOL doneFetching, NSArray *members, NSError *error) {
        
        if (doneFetching)[self.activityView stopAnimating];
        
        if (error) {

           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                               message:[error localizedDescription]
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                     otherButtonTitles:nil];
           [alertView show];

        } else {

            
            if (!self.members) {
                self.members = [[NSMutableArray alloc] initWithCapacity:members.count];
            }
            
            if (members.count > 0) {
                [self.members addObjectsFromArray:members];           
                [self.tableView reloadData];
            }
        }
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.group.name;
    
    // Loading indicator.
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44.f)];
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView.center = footerView.center;
    [footerView addSubview:self.activityView];
    self.tableView.tableFooterView = footerView;
    
    [self setupFetchManager];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MemberCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Member *member = [self.members objectAtIndex:indexPath.row];
    
    // Profile photo.
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.clipsToBounds = YES;
    [cell.imageView setImageWithURL:[NSURL URLWithString:member.photoURL] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    
    // Member name.
    cell.textLabel.text = member.name;
    
    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == (self.members.count-1) - tableView.visibleCells.count) {
        
        [self loadMembers];
    }
}

@end
