//
//  InformationViewController.m
//  Photo
//
//  Created by wangshuai on 13-9-17.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "InformationViewController.h"
#import "ImageCache.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "FollowingViewController.h"
#import "FollowerViewController.h"
#import "AppDelegate.h"
#import "UserDB.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingViewController.h"
#import "ImageDownload.h"
#import <arcstreamsdk/STreamUser.h>

#define BIG_IMG_WIDTH  240.0
#define BIG_IMG_HEIGHT 240.0
@interface InformationViewController ()
{
    ImageCache *cache;
    STreamQuery *sq;
    NSMutableArray *arrayCount;
    STreamObject *so;
    NSMutableDictionary *userMetaData;
    int count;
    BOOL isFollowing;
    STreamObject *following;
    STreamObject *follower;
    NSArray *allFollowingKey;
    NSArray *allFollowerKey;
    NSArray *followerKey;
    NSString *pageUserName;
    NSMutableArray *array;
    NSMutableArray *loggedInUserFollowing;
    NSString *pImageId;
    int threeCount;
    int fourCount;
    UIActivityIndicatorView *imageViewActivity;
    UIView *background;
    NSMutableDictionary * nickNameDict;
}
@end

@implementation InformationViewController

@synthesize myTableView;
@synthesize nameLablel;
@synthesize lable;
@synthesize countLable;
@synthesize imageView;
@synthesize userName;
@synthesize isPush;
@synthesize followerButton;
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    [self.myTableView reloadData];
}
-(void)pickerDoneClicked
{
    UITextView* view = (UITextView*)[self.view viewWithTag:1001];
    [view resignFirstResponder];
}
-(void)selectClickedAction
{
    SettingViewController * setView= [[SettingViewController alloc]init];
    [self.navigationController pushViewController:setView animated:YES];
}
-(void)referen
{
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"读取中...";
    [self.view addSubview:HUD];
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadDetails];
    }completionBlock:^{
        [self.myTableView reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    cache = [ImageCache sharedObject];
    if (userName != nil)
        pageUserName = userName;
    else
        pageUserName = [cache getLoginUserName];
    nickNameDict = [cache getUserMetadata:pageUserName];
    if ([pageUserName isEqualToString:[cache getLoginUserName]]) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(selectClickedAction)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    UIBarButtonItem *refrenItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(referen)];
    self.navigationItem.rightBarButtonItem = refrenItem;
	// Do any additional setup after loading the view.
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [self.view addSubview:myTableView];
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:myTableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    myTableView.backgroundView = backgrdView;
    
   __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"读取中...";
    [self.view addSubview:HUD];
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadDetails];
     }completionBlock:^{
        [self.myTableView reloadData];
          [HUD removeFromSuperview];
         HUD = nil;
     }];
}

- (void)loadDetails{
   
    //TODO CHECK query no connection
    sq = [[STreamQuery alloc] initWithCategory:@"Voted"];
    [sq addLimitId:pageUserName];
    arrayCount = [sq find];
    if (arrayCount!= nil && [arrayCount count] == 1)
        so = [arrayCount objectAtIndex:0];
    
    
    follower = [[STreamObject alloc]init];
    [follower loadAll:[NSString stringWithFormat:@"%@Follower", pageUserName]];
    allFollowerKey = [follower getAllKeys];
    
    following  = [[STreamObject alloc]init];
    [following loadAll:[NSString stringWithFormat:@"%@Following",pageUserName]];
    allFollowingKey = [following getAllKeys];
    
    sq = [[STreamQuery alloc] initWithCategory:@"AllVotes"];
    [sq setQueryLogicAnd:true];
    [sq whereEqualsTo:@"flag" forValue:@"false"];
    [sq whereEqualsTo:@"userName" forValue:pageUserName];
    array = [sq find];
    
    STreamObject *loggedInUserFollowingStream = [[STreamObject alloc] init];
    [loggedInUserFollowingStream loadAll:[NSString stringWithFormat:@"%@Following",[cache getLoginUserName]]];
    loggedInUserFollowing = [NSMutableArray arrayWithArray:[loggedInUserFollowingStream getAllKeys]];

}

//创建cell上控件
-(void)createUIControls:(UITableViewCell *)cell withCellRowAtIndextPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        imageViewActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [imageViewActivity setCenter:CGPointMake(50, 50)];
        [imageViewActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [cell addSubview:imageViewActivity];
        [imageViewActivity startAnimating];
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 80, 80)];
        imageView.image = [UIImage imageNamed:@"headImage.jpg"];
        [cell.contentView addSubview:imageView];
        
        nameLablel = [[UILabel alloc]initWithFrame:CGRectMake(102, 20, 120, 40)];
        nameLablel.textColor = [UIColor blackColor];
//        nameLablel.textAlignment = NSTextAlignmentCenter;
//        nameLablel.font = [UIFont fontWithName:@"Arial" size:20];
        nameLablel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLablel];

        followerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[followerButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[followerButton  layer] setBorderWidth:1];
        [[followerButton layer] setCornerRadius:8];
        [followerButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [followerButton setFrame:CGRectMake(225, 40, 75, 30)];
        [followerButton.titleLabel setFont:[UIFont fontWithName:@"Arial" size:14.0f]];
        [followerButton addTarget:self action:@selector(followButton:) forControlEvents:UIControlEventTouchUpInside];
        if (isPush && ![userName isEqualToString:[cache getLoginUserName]]) {
            [cell.contentView addSubview:followerButton];
        }else{
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        
        image = [[UIImageView alloc]initWithFrame:CGRectMake(8, 9, 32, 32)];
        [cell.contentView addSubview:image];
        
        lable = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 240, 50)];
        lable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lable];
        
        countLable = [[UILabel alloc]initWithFrame:CGRectMake(230, 0, 60, 50)];
        countLable.textAlignment = NSTextAlignmentRight;
        countLable.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:countLable];
    }

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [self createUIControls:cell withCellRowAtIndextPath:indexPath];
        cell.selectionStyle = UITableViewCellAccessoryNone;
    }

  
        if ([loggedInUserFollowing containsObject:pageUserName]) {
        [followerButton setTitle:@"取消关注" forState:UIControlStateNormal];
    }else{
        [followerButton setTitle:@"关注" forState:UIControlStateNormal];
    }
    
    NSArray * dataArray =[[NSArray alloc]initWithObjects:@"上传信息",@"投票数",@"关注的人",@"粉丝",nil];
    NSArray *imageArray = [[NSArray alloc]initWithObjects:@"upload1.png",@"vote.png",@"following.png",@"follower.png", nil];
    if (indexPath.row == 0){
        [self loadUserMetadataAndDownloadUserProfileImage];
    }
    
    if (indexPath.row ==1) {
        lable.text = [dataArray objectAtIndex:indexPath.row-1];
        image.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row-1]];
        countLable.text =[NSString stringWithFormat:@"%d",[array count]];
        count = [countLable.text intValue];
    }
    if (indexPath.row ==2) {
        lable.text = [dataArray objectAtIndex:indexPath.row-1];
        image.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row-1]];
        if ([so size]==0) {
            countLable.text = @"0";
        }else{
            countLable.text = [NSString stringWithFormat:@"%d",[so size]];
        }
    }
    if (indexPath.row ==3) {
        lable.text = [dataArray objectAtIndex:indexPath.row-1];
        image.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row-1]];
        countLable.text =[NSString stringWithFormat:@"%d",[allFollowingKey count]];
        threeCount = [countLable.text intValue];
    }
    if (indexPath.row ==4) {
        image.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row-1]];
        lable.text = [dataArray objectAtIndex:indexPath.row-1];
        countLable.text =[NSString stringWithFormat:@"%d",[allFollowerKey count]];
        fourCount = [countLable.text intValue];
    }
    NSString * nickname = [nickNameDict objectForKey:@"nickname"];

    if (!nickname){
         nameLablel.text = pageUserName;
    }else{
        nameLablel.text = nickname;
    }
    return cell;
}
- (void)loadUserMetadataAndDownloadUserProfileImage{
    
    //load user metadata and profile image
    if ([cache getUserMetadata:pageUserName] != nil){
        userMetaData = [cache getUserMetadata:pageUserName];
        pImageId = [userMetaData objectForKey:@"profileImageId"];
        if ([cache getImage:pImageId] == nil && pImageId){
            ImageDownload *imageDownload = [[ImageDownload alloc] init];
            [imageDownload downloadFile:pImageId];
        }else{
           if (pImageId)
               [self.imageView setImage:[UIImage imageWithData:[cache getImage:pImageId]]];
        }
        [imageViewActivity stopAnimating];
    }else{
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:pageUserName response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:pageUserName]){
                NSMutableDictionary *dic = [user userMetadata];
                [cache saveUserMetadata:pageUserName withMetadata:dic];
            }
        }];
    }
    
}
-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 100;
    }else{
        return 50;
    }
}
-(void)reloadTable
{
    [self.myTableView reloadData];
}
- (void)followAction{
 
    STreamObject *loggedInUser = [[STreamObject alloc] init];
    [loggedInUser setObjectId:[NSString stringWithFormat:@"%@Following", [cache getLoginUserName]]];
    [loggedInUser addStaff:pageUserName withObject:@""];
    [loggedInUser update];
    
    [follower addStaff:[cache getLoginUserName] withObject:@""];
    [follower update];
    
    
    //for table view update
    allFollowerKey = [follower getAllKeys];
    [loggedInUserFollowing addObject:pageUserName];

}

- (void)unFollowAction{
    
    STreamObject *loggedInUser = [[STreamObject alloc] init];
    [loggedInUser removeKey:pageUserName forObjectId:[NSString stringWithFormat:@"%@Following", [cache getLoginUserName]]];
    [follower removeKey:[cache getLoginUserName] forObjectId:[NSString stringWithFormat:@"%@Follower", pageUserName]];
    //for table view update
    [loggedInUserFollowing removeObject:pageUserName];
    allFollowingKey = [following getAllKeys];
    allFollowerKey = [follower getAllKeys];
    
}

//follow/unfollow
-(void)followButton:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"关注"]){
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"关注...";
            [self.view addSubview:HUD];
        
            [HUD showAnimated:YES whileExecutingBlock:^{
                [self followAction];
            }completionBlock:^{
               [self.myTableView reloadData];
                 [HUD removeFromSuperview];
                HUD = nil;
            }];
        return;
    }
   
    
    if ([button.titleLabel.text isEqualToString:@"取消关注"]) {
        __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.labelText = @"取消关注...";
        [self.view addSubview:HUD];
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self unFollowAction];
        }completionBlock:^{
            [self.myTableView reloadData];
             [HUD removeFromSuperview];
            HUD = nil;
        }];
    }
   
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath .row == 0) {
        [self fangda];
    }
    if (indexPath.row == 1) {
        if (count!=0)   {
            MainViewController * mainVC = [[MainViewController alloc]init];
            mainVC.isPush = YES;
            mainVC.userName = pageUserName;
           [self.navigationController pushViewController:mainVC animated:YES];
        }
    }
    if (indexPath.row == 2) {
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"读取中...";
            [self.view addSubview:HUD];
            MainViewController * mainVC = [[MainViewController alloc]init];
            [HUD showAnimated:YES whileExecutingBlock:^{
                STreamQuery *queryVotes = [[STreamQuery alloc]initWithCategory:@"Voted"];
               [queryVotes addLimitId:pageUserName];
                NSMutableArray *votesResult = [queryVotes find];
                STreamObject *result = [votesResult objectAtIndex:0];
                NSArray *keys = [result getAllKeys];
                STreamQuery *sqq = [[STreamQuery alloc] initWithCategory:@"AllVotes"];
                for (NSString *key in keys){
                    [sqq addLimitId:key];
                }
                [sqq whereEqualsTo:@"flag" forValue:@"false"];
                NSMutableArray *resultVotes = [sqq find];
                [mainVC setVotesArray:resultVotes];
                mainVC.isPush = YES;
                mainVC.isPushFromVotesGiven = YES;
                mainVC.userName = pageUserName;
            } completionBlock:^{
                [self.navigationController pushViewController:mainVC animated:YES];
                 [HUD removeFromSuperview];
                HUD = nil;
            }];
        
    }
    //following
    if (indexPath.row == 3) {
        if (threeCount) {
            FollowingViewController *followingView = [[FollowingViewController alloc]init];
            [followingView setUserName:pageUserName];
            [self.navigationController pushViewController:followingView animated:YES];
        }
    }
    //follower
    if (indexPath.row == 4) {
        if (fourCount) {
            FollowerViewController *followerView = [[FollowerViewController alloc]init];
            [followerView setFollowerArray:allFollowerKey];
            [followerView setUserName:pageUserName];
            [self.navigationController pushViewController:followerView animated:YES];
        }
    }
}
//fangda
- (void)fangda
{
    //创建灰色透明背景，使其背后内容不可操作
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    background = bgView;
    [bgView setBackgroundColor:[UIColor colorWithRed:0.3
                                               green:0.3
                                                blue:0.3
                                               alpha:0.7]];
    [self.myTableView addSubview:bgView];
    //创建边框视图
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,BIG_IMG_WIDTH+16, BIG_IMG_HEIGHT+16)];
    //将图层的边框设置为圆脚
    borderView.layer.cornerRadius = 8;
    borderView.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    borderView.layer.borderWidth = 8;
    borderView.layer.borderColor = [[UIColor colorWithRed:0.9
                                                    green:0.9
                                                     blue:0.9
                                                    alpha:0.7]CGColor];
    [borderView setCenter:bgView.center];
    [bgView addSubview:borderView];
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"remove.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(suoxiao) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(borderView.frame.origin.x+borderView.frame.size.width-20, borderView.frame.origin.y-6, 26, 27)];
    [bgView addSubview:closeBtn];
    //创建显示图像视图
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, BIG_IMG_WIDTH, BIG_IMG_HEIGHT)];
    [imgView setImage:[UIImage imageWithData:[cache getImage:pImageId]]];
    [borderView addSubview:imgView];
    [self shakeToShow:borderView];//放大过程中的动画

    
    //动画效果
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:2.6];//动画时间长度，单位秒，浮点数
    [self.myTableView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    [UIView setAnimationDelegate:bgView];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}
-(void)suoxiao
{
    [background removeFromSuperview];
}
//*************放大过程中出现的缓慢动画*************
- (void) shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
