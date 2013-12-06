//
//  FollowingViewController.m
//  Photo
//
//  Created by wangsh on 13-9-27.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "FollowingViewController.h"
#import "InformationViewController.h"
#import "ImageCache.h"
#import "MBProgressHUD.h"
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamUser.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageDownload.h"

@interface FollowingViewController ()
{
    ImageCache * cache;
    NSMutableDictionary *userMetaData;
    NSMutableArray *loggedInUserFollowing; 
    NSMutableArray *userFollowing;
    UIActivityIndicatorView *imageViewActivity;
    NSString * key;
    
    NSString * pageUserName;
    STreamObject *loggedInUser;
    STreamObject *follower;
}
@end

@implementation FollowingViewController
@synthesize imageView;
@synthesize nameLabel;
@synthesize followingButton;
@synthesize userName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关注";
    cache = [ImageCache sharedObject];
    
    STreamObject *loggedInUserFollowingStream = [[STreamObject alloc] init];
    [loggedInUserFollowingStream loadAll:[NSString stringWithFormat:@"%@Following",[cache getLoginUserName]]];
    loggedInUserFollowing = [NSMutableArray arrayWithArray:[loggedInUserFollowingStream getAllKeys]];
    
    STreamObject *userFollowingStream = [[STreamObject alloc] init];
    [userFollowingStream loadAll:[NSString stringWithFormat:@"%@Following",userName]];
    userFollowing = [NSMutableArray arrayWithArray:[userFollowingStream getAllKeys]];
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:self.tableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    self.tableView.backgroundView = backgrdView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userFollowing count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellAccessoryNone;

        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        
        imageViewActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [imageViewActivity setCenter:CGPointMake(30,22)];
        [imageViewActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
       // [cell addSubview:imageViewActivity];
       // [imageViewActivity startAnimating];

        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 2, 40, 40)];
        [imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        [cell.contentView addSubview:imageView];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 140, 44)];
        nameLabel.font = [UIFont fontWithName:@"Arial" size:16.0f];
        nameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLabel];
        
        followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [followingButton setFrame:CGRectMake(210, 7, 75, 30)];
        followingButton.tag = indexPath.row;
        [followingButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [followingButton addTarget:self action:@selector(followingButton:) forControlEvents:UIControlEventTouchUpInside];
         [cell.contentView addSubview:followingButton];
    }
    if ([userName isEqualToString:[cache getLoginUserName]]) {
        [followingButton setTitle:@"取消关注" forState:UIControlStateNormal];
        
        [[followingButton  layer] setBorderWidth:1];
        [[followingButton layer] setCornerRadius:8];
        [[followingButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [followingButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
    }else{
        key = [userFollowing objectAtIndex:indexPath.row];
        if ([loggedInUserFollowing containsObject:key]) {
            [[followingButton  layer] setBorderWidth:1];
            [[followingButton layer] setCornerRadius:8];
            [[followingButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
            [followingButton setTitle:@"取消关注" forState:UIControlStateNormal];
            [followingButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }else{
            if ([key isEqualToString:[cache getLoginUserName]]) {
                
            }else{
                [[followingButton  layer] setBorderWidth:1];
                [[followingButton layer] setCornerRadius:8];
                [[followingButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
                [followingButton setTitle:@"关注" forState:UIControlStateNormal];
                [followingButton setTitleColor:[UIColor redColor]  forState:UIControlStateNormal];
            }
            
        }
    }
    
    
    //download usermeta data and user image
    NSString *currentRowUserName = [userFollowing objectAtIndex:indexPath.row];
    userMetaData = [cache getUserMetadata:currentRowUserName];
    nameLabel.text = currentRowUserName;
    if (userMetaData){
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if (pImageId && ![cache getImage:pImageId]){
            ImageDownload *imageDownload = [[ImageDownload alloc] init];
            [imageDownload downloadFile:pImageId];
            [imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        }else{
            if (pImageId)
                [imageView setImage:[UIImage imageWithData:[cache getImage:pImageId]]];
        }
    }else{
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:currentRowUserName response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:currentRowUserName]){
                NSMutableDictionary *dic = [user userMetadata];
                [cache saveUserMetadata:currentRowUserName withMetadata:dic];
            }
        }];
        [imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
    }
    
    //assign nicky name
    if (userMetaData){
        NSString *nickyName = [userMetaData objectForKey:@"nickname"];
        if (nickyName && ![nickyName isEqualToString:@""])
            nameLabel.text = nickyName;
    }

    
    cell.tag = indexPath.row;
    return cell;
}
- (void)followAction{
    [loggedInUser setObjectId:[NSString stringWithFormat:@"%@Following", [cache getLoginUserName]]];
    [loggedInUser addStaff:pageUserName withObject:@""];
    [loggedInUser update];
    
    STreamObject *keyFollower = [[STreamObject alloc]init];
    [keyFollower setObjectId:[NSString stringWithFormat:@"%@Follower", pageUserName]];
    [keyFollower addStaff:[cache getLoginUserName] withObject:@""];
    [keyFollower update];
    
    //for table view update
    [loggedInUserFollowing addObject:pageUserName];
}
- (void)unFollowAction{
    [loggedInUser removeKey:pageUserName forObjectId:[NSString stringWithFormat:@"%@Following", [cache getLoginUserName]]];
    [follower removeKey:[cache getLoginUserName] forObjectId:[NSString stringWithFormat:@"%@Follower",pageUserName]];
    //for table view update
    [loggedInUserFollowing removeObject:pageUserName];

}

-(void)followingButton:(UIButton *)button
{
    pageUserName = [userFollowing objectAtIndex:button.tag];
    loggedInUser = [[STreamObject alloc] init];
    follower = [[STreamObject alloc]init];

     if ([userName isEqualToString:[cache getLoginUserName]]) {
        NSArray *visiblecells = [self.tableView visibleCells];
        for(UITableViewCell *cell in visiblecells)
        {
            if(cell.tag == button.tag)
            {
                __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                HUD.labelText = @"取消关注...";
                [self.view addSubview:HUD];
                [HUD showAnimated:YES whileExecutingBlock:^{
                    [self unFollowAction];
                }completionBlock:^{
                    [userFollowing removeObjectAtIndex:[cell tag]];
                    [self.tableView reloadData];
                     [HUD removeFromSuperview];
                    HUD = nil;
                }];
                break;
            }
        }
    }else{
        if ([button.titleLabel.text isEqualToString:@"取消关注"]) {
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"取消关注...";
            [self.view addSubview:HUD];
            [HUD showAnimated:YES whileExecutingBlock:^{
                [self unFollowAction];
            }completionBlock:^{
                [self.tableView reloadData];
                 [HUD removeFromSuperview];
                HUD = nil;
            }];
            return;
        }
         if ([button.titleLabel.text isEqualToString:@"关注"]) {
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"关注...";
            [self.view addSubview:HUD];
            [HUD showAnimated:YES whileExecutingBlock:^{
                [self followAction];
            }completionBlock:^{
                [self.tableView reloadData];
                 [HUD removeFromSuperview];
                HUD = nil;
            }];
         }
    }
    [self.tableView reloadData];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InformationViewController *inforView = [[InformationViewController alloc]init];
    [inforView setUserName:[userFollowing objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:inforView animated:YES];
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
