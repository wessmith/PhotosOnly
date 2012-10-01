//
//  POGroupViewController.m
//  PhotosOnly
//
//  Created by Wesley Smith on 10/1/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "POGroupViewController.h"
#import "Group.h"

@interface POGroupViewController ()

@property (nonatomic, strong) NSArray *groups;

@end

@implementation POGroupViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadGroups
{
    [Group groupsWithBlock:^(NSArray *groups, NSError *error) {
        
        if (error) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else {
            
            self.groups = groups;
            [self.tableView reloadData];
        }
        
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Meetup Groups", nil);
    
    [self loadGroups];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MembersViewSegue"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Group *group = [self.groups objectAtIndex:indexPath.row];
        
        id controller = segue.destinationViewController;
        [controller setValue:group forKey:@"group"];
    }
}

#pragma mark - Table view data source

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Group *group = [self.groups objectAtIndex:indexPath.row];
    
    // Group photo.
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.clipsToBounds = YES;
    [cell.imageView setImageWithURL:[NSURL URLWithString:group.photoURL] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    
    // Group name.
    cell.textLabel.text = group.name;
    
    // Group member count.
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ members", group.members];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
