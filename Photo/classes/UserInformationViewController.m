//
//  UserInformationViewController.m
//  Photo
//
//  Created by wangsh on 13-9-28.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "UserInformationViewController.h"
#import "MBProgressHUD.h"
#import "InformationViewController.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamUser.h>
#import "ImageCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageDownload.h"

@interface UserInformationViewController ()
{
    UIActivityIndicatorView *imageViewActivity;
    STreamObject *so;
    NSMutableArray *nameArray;
    NSMutableArray *sos;
    ImageCache *cache;
     NSMutableArray *loggedInUserFollowing;
    
    NSString *pageUserName;
    STreamObject *loggedInUser;
    STreamObject *follower;
    NSMutableDictionary * nickNameDict;
}
@end

@implementation UserInformationViewController
@synthesize headImage;
@synthesize nameLabel;
@synthesize votesLabel;
@synthesize followButton;

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
	// Do any additional setup after loading the view.
    
    cache = [ImageCache sharedObject];
    nameArray = [[NSMutableArray alloc]init];
    sos = [[NSMutableArray alloc]init];
    nickNameDict  = [[NSMutableDictionary alloc]init];
    //background
    UIView *backgrdView = [[UIView alloc] initWithFrame:self.tableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    self.tableView.backgroundView = backgrdView;
    
    STreamObject *loggedInUserFollowingStream = [[STreamObject alloc] init];
    [loggedInUserFollowingStream loadAll:[NSString stringWithFormat:@"%@Following",[cache getLoginUserName]]];
    loggedInUserFollowing = [NSMutableArray arrayWithArray:[loggedInUserFollowingStream getAllKeys]];
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"读取中...";
    [self.view addSubview:HUD];
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadDetails];
    }completionBlock:^{
        [self.tableView reloadData];
        HUD = nil;
    }];
    
}

- (void)loadDetails{
    STreamQuery *sq = [[STreamQuery alloc] initWithCategory:@"Voted"];
    sos = [sq listSortedStreamObjectsBasedOnKeySize:10];
    for ( STreamObject *sto in sos) {
        [nameArray addObject:[sto objectId]];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nameArray count];
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
        [imageViewActivity setCenter:CGPointMake(30,30)];
        [imageViewActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [cell addSubview:imageViewActivity];
        [imageViewActivity startAnimating];
        
        headImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        [headImage setImage:[UIImage imageNamed:@"headImage.jpg"]];
        [cell.contentView addSubview:headImage];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 120, 40)];
        nameLabel.font = [UIFont fontWithName:@"Arial" size:16.0f];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLabel];
        
        votesLabel = [[UILabel alloc]initWithFrame:CGRectMake(210, 0, 75, 30)];
        votesLabel.font = [UIFont fontWithName:@"Arial" size:16.0f];
        votesLabel.textAlignment = NSTextAlignmentCenter;
        votesLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:votesLabel];
        
        followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[followButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[followButton  layer] setBorderWidth:1];
         [[followButton layer] setCornerRadius:8];
        
        [followButton setFrame:CGRectMake(210, 30, 75, 30)];
        followButton.tag = indexPath.row;
        [followButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [followButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [followButton addTarget:self action:@selector(followButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
       
    }
    if ([[nameArray objectAtIndex:indexPath.row] isEqualToString:[cache getLoginUserName]]) {
        votesLabel.frame =CGRectMake(210, 10, 75, 40);
    }else{
        [cell addSubview:followButton];
        if ([loggedInUserFollowing containsObject:[nameArray objectAtIndex:indexPath.row]]) {
            [followButton setTitle:@"取消关注" forState:UIControlStateNormal];
            [followButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }else{
            [followButton setTitle:@"关注" forState:UIControlStateNormal];
            [followButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }

    }
    
    /*read metadata first, then load image data */
    NSString *rowUserName = [nameArray objectAtIndex:indexPath.row];
    NSMutableDictionary *userMetaData = [cache getUserMetadata:rowUserName];
    if (!userMetaData){
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:rowUserName response:^(BOOL succeed, NSString *response){
            if ([response isEqualToString:rowUserName]){
                NSMutableDictionary *dic = [user userMetadata];
                [cache saveUserMetadata:rowUserName withMetadata:dic];
            }
        }];
    }else{
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if ([cache getImage:pImageId] == nil && pImageId){
            ImageDownload *imageDownload = [[ImageDownload alloc] init];
            [imageDownload downloadFile:pImageId];
        }else{
           if (pImageId)
               [self.headImage setImage:[UIImage imageWithData:[cache getImage:pImageId]]];
            [imageViewActivity stopAnimating];
        }
    }
    
    

    so =[sos objectAtIndex:indexPath.row];
    nickNameDict = [cache getUserMetadata:[nameArray objectAtIndex:indexPath.row]];
    NSString *nickname = [nickNameDict objectForKey:@"nickname"];
    if (!nickname)
        nameLabel.text = [nameArray objectAtIndex:indexPath.row];
    else
        nameLabel.text = nickname;
   // nameLabel.text = [nameArray objectAtIndex:indexPath.row];

    votesLabel.text = [NSString stringWithFormat:@"%d",[so size]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InformationViewController *inforView = [[InformationViewController alloc]init];
    [inforView setUserName:[nameArray objectAtIndex:indexPath.row ]];
    inforView.isPush = YES;
    [self.navigationController pushViewController:inforView animated:YES];
}
- (void)followAction{
    
    [loggedInUser setObjectId:[NSString stringWithFormat:@"%@Following", [cache getLoginUserName]]];
    [loggedInUser addStaff:pageUserName withObject:@""];
    [loggedInUser update];
    
    [follower addStaff:[cache getLoginUserName] withObject:@""];
    [follower update];
    
    //for table view update
    [loggedInUserFollowing addObject:pageUserName];
    
}

- (void)unFollowAction{

    [loggedInUser removeKey:pageUserName forObjectId:[NSString stringWithFormat:@"%@Following", [cache getLoginUserName]]];
    [follower removeKey:[cache getLoginUserName] forObjectId:[NSString stringWithFormat:@"%@Follower",pageUserName]];
    //for table view update
    [loggedInUserFollowing removeObject:pageUserName];
    [loggedInUser loadAll:[NSString stringWithFormat:@"%@Following", [cache getLoginUserName]]];
    
}
-(void)followButtonClicked:(UIButton *)button{
     pageUserName = [nameArray objectAtIndex:button.tag];
    loggedInUser = [[STreamObject alloc] init];
    follower = [[STreamObject alloc]init];
    [follower loadAll:[NSString stringWithFormat:@"%@Follower", pageUserName]];
    
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
    [self.tableView reloadData];
 
}

@end
