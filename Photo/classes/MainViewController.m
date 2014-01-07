//
//  MainViewController.m
//  Photo
//
//  Created by wangshuai on 13-9-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "MainViewController.h"
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamSession.h>
#import "MBProgressHUD.h"
#import "ImageCache.h"
#import "ImageDownload.h"
#import "YIFullScreenScroll.h"
#import "LoginViewController.h"
#import "VotesShowViewController.h"
#import "InformationViewController.h"
#import "CommentsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UserDB.h"
#import "AppDelegate.h"
#define BIG_IMG_WIDTH  300.0
#define BIG_IMG_HEIGHT 300.0

@interface MainViewController (){
    STreamCategoryObject *votes;   
    YIFullScreenScroll* _fullScreenDelegate;
    STreamQuery *st;
    NSMutableDictionary *loggedInUserVotesResults;
    
    UIActivityIndicatorView *imageViewActivity;
    UIActivityIndicatorView *oneImageViewActivity;
    UIActivityIndicatorView *twoImageViewActivity;
    
    NSString *currentSelectedMessage;
    UIView *background;
    BOOL isRight;
    int timeCount;
    int arrayCount;
    NSString *userNameToBeChecked;
    BOOL isReport;
    NSInteger tag;
}

@end

@implementation MainViewController
@synthesize myTableView = _myTableView;
@synthesize name = _name;
@synthesize message = _message;
@synthesize oneImageView =_oneImageView;
@synthesize twoImageView =_twoImageView;
@synthesize vote1Lable = _vote1Lable;
@synthesize vote2Lable = _vote2Lable;
@synthesize timeLabel;
@synthesize timeImage;
@synthesize clickButton;
@synthesize commentButton;
@synthesize reportButton;
@synthesize isPush;
@synthesize userName;
@synthesize votesArray;
@synthesize isPushFromVotesGiven;
@synthesize selectOneImage;
@synthesize selectTwoImage;
@synthesize loadMoreButton;



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
    NSLog(@"");
}

- (void) initBarRefresh{
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshiClicked)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"主页";
    timeCount = 1;
    isReport = NO;
    [self initBarRefresh];
    
    loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loadMoreButton setFrame:CGRectMake(10, 2, 300, 40)];
    [loadMoreButton setTitle:@"加载更多" forState:UIControlStateNormal];
    [loadMoreButton addTarget:self action:@selector(loadMoreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loadMoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    loadMoreButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    votes = [[STreamCategoryObject alloc] initWithCategory:@"AllVotes"];
    loggedInUserVotesResults = [[NSMutableDictionary alloc] init];
    ImageCache *cache = [ImageCache sharedObject];
    if ([cache getLoginUserName]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>= 7.0) {
            self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            _fullScreenDelegate = [[YIFullScreenScroll alloc] initWithViewController:self];
            _fullScreenDelegate.shouldShowUIBarsOnScrollUp = YES;
        }else{
            self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        }
    }else{
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>= 7.0) {
            self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }else{
            self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
        }

    }
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.separatorStyle=YES;//UITableView每个cell之间的默认分割线隐藏掉sel
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    [self.view addSubview:self.myTableView];
    //background
    UIView *backgrdView = [[UIView alloc] initWithFrame:_myTableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    _myTableView.backgroundView = backgrdView;
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"读取中...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadVotes];
    }completionBlock:^{
        [self.myTableView reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}
- (NSString *)getTimeDiff:(long)diff{
    
    int seconds = (int)(diff);
    if (seconds <= 60) 
        return [NSString stringWithFormat:@"%d秒前", seconds];
    int mins = seconds / 60;
    if (mins <= 60)
        return [NSString stringWithFormat:@"%d分前", mins];
    int hours = seconds / 3600;
    if (hours <= 24)
        return [NSString stringWithFormat:@"%d小时前", hours];
    int days = hours / 24;
    if (days <= 30)
        return [NSString stringWithFormat:@"%d天前", days];
    int months = days / 365;
    if (months <= 12)
        return [NSString stringWithFormat:@"%d月前", months];
    
    int years = months / 12;
    return [NSString stringWithFormat:@"%d年前", years];
   
}
-(void)refreshiClicked{
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self refresh];
    }completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
        [self.myTableView reloadData];
    }];
}

- (void)refresh{
    
    STreamObject *latest = [votesArray objectAtIndex:0];
    NSString *time = [latest getValue:@"creationTime"];
    
    NSDate *latestDay = [[NSDate alloc] initWithTimeIntervalSince1970:[time longLongValue]];
    
    STreamQuery *sq = [[STreamQuery alloc] initWithCategory:@"AllVotes"];
    
    [sq setQueryLogicAnd:TRUE];
    [sq afterDate:@"creationTime" after:latestDay];
    [sq whereEqualsTo:@"flag" forValue:@"false"];
    
    NSMutableArray *newVote = [sq find];
    
    NSArray *newArray = [newVote arrayByAddingObjectsFromArray:votesArray];

    [votesArray setArray:newArray];
}

- (void)calculateVoteResults:(NSString *)userNameTobeChecked {
    ImageCache *imageCache = [ImageCache sharedObject];
    
    st = [[STreamQuery alloc] initWithCategory:@"Voted"];
    [st setQueryLogicAnd:FALSE];
    for (STreamObject *allVotes in votesArray){
        [st whereKeyExists:[allVotes objectId]];
    }
    NSMutableArray *results = [st find];
    for (STreamObject *allVotes in votesArray){
        int f1 = 0;
        int f2 = 0;
        VoteResults *vo = [[VoteResults alloc] init];
        int saved = 0;
        for (STreamObject *vote in results){
            NSString *voted = [vote getValue:[allVotes objectId]];
            if (voted != nil && ([userNameTobeChecked isEqualToString:[vote objectId]]) && saved != 1){
                [loggedInUserVotesResults setObject:vote forKey:[allVotes objectId]];
                saved = 1;
            }
            if (voted != nil && [voted isEqualToString:@"f1voted"])
                f1++;
            if (voted != nil && [voted isEqualToString:@"f2voted"])
                f2++;
        }
        saved = 0;
        int total = f1 + f2;
        int vote1count;
        int vote2count;
        if (total) {
            vote1count = ((float)f1/total)*100;
            vote2count = ((float)f2/total)*100;
            NSString *vote1 = [NSString stringWithFormat:@"%d%%",vote1count];
            NSString *vote2 = [NSString stringWithFormat:@"%d%%",vote2count];
            
            [vo setObjectId:[allVotes objectId]];
            [vo setF1:vote1];
            [vo setF2:vote2];
            
            [imageCache addVotesResults:[allVotes objectId] withVoteResult:vo];
            
        }else{
            vote1count=0;
            vote2count=0;
        }
    }
}

- (void)loadVotes{
    
    if (isPush) {
        userNameToBeChecked = userName;
        if (!isPushFromVotesGiven){
            st = [[STreamQuery alloc] initWithCategory:@"AllVotes"];
            [st setQueryLogicAnd:TRUE];
            [st whereEqualsTo:@"userName" forValue:userName];
            [st whereEqualsTo:@"flag" forValue:@"false"];
            votesArray = [st find];
        }
    }else{
        STreamQuery *sq = [[STreamQuery alloc] initWithCategory:@"AllVotes"];
        NSDate *now = [[NSDate alloc] init];
        long millionsSecs = [now timeIntervalSince1970];
        long dayBefore = millionsSecs - (3600 *3500*timeCount);
        
        NSDate *dayBe = [[NSDate alloc] initWithTimeIntervalSince1970:dayBefore];
        [sq setQueryLogicAnd:true];
        [sq afterDate:@"creationTime" after:dayBe];
        [sq whereEqualsTo:@"flag" forValue:@"false"];
        //TODO CHECK query no connection
        votesArray = [sq find];
        [votesArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            STreamObject *so1 = (STreamObject *)obj1;
            STreamObject *so2 = (STreamObject *)obj2;
            NSString *t1 = [so1 getValue:@"creationTime"];
            NSString *t2 = [so2 getValue:@"creationTime"];

            return [t2 compare:t1];

        }];
        st = [[STreamQuery alloc] initWithCategory:@"Voted"];
        ImageCache *cache = [ImageCache sharedObject];
        userNameToBeChecked  = [cache getLoginUserName];
    }
    
    [self calculateVoteResults:userNameToBeChecked];
}


-(void)loadMoreButtonClicked
{
    arrayCount = [votesArray count];
    timeCount++;
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadVotes];
    }completionBlock:^{
        [HUD removeFromSuperview];
         HUD = nil;
        [self.myTableView reloadData];
        if (arrayCount == [votesArray count]) {
            [loadMoreButton setTitle:@"没有更多内容" forState:UIControlStateNormal];
        }else{
            [loadMoreButton setTitle:@"加载更多" forState:UIControlStateNormal];
        }
       
    }];

}
//创建cell上控件
-(void)createUIControls:(UITableViewCell *)cell withCellRowAtIndextPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [votesArray count]) {
        [cell addSubview:loadMoreButton];
    }else{
        imageViewActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [imageViewActivity setCenter:CGPointMake(35, 44)];
        [imageViewActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [cell addSubview:imageViewActivity];
        [imageViewActivity startAnimating];
        
        oneImageViewActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [oneImageViewActivity setCenter:CGPointMake(77, 200)];
        [oneImageViewActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [cell addSubview:oneImageViewActivity];
        [oneImageViewActivity startAnimating];
        
        twoImageViewActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [twoImageViewActivity setCenter:CGPointMake(240, 200)];
        [twoImageViewActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [cell addSubview:twoImageViewActivity];
        [twoImageViewActivity startAnimating];
        
        
        self.imageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.imageView setFrame:CGRectMake(5, 15, 60, 60)];
        [self.imageView setImage:[UIImage imageNamed:@"headImage.jpg"] forState:UIControlStateNormal];
        [self.imageView setTag:indexPath.row];
        [self.imageView addTarget:self action:@selector(headImageClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.imageView];
        
        self.name = [[UITextField alloc]initWithFrame:CGRectMake(90, 10, 200, 30)];
        self.name.enabled = NO;
        [cell.contentView addSubview:self.name];
        
        self.message = [[UILabel alloc]initWithFrame:CGRectMake(90, 40, 200, 40)];
        self.message.font =[UIFont systemFontOfSize:15.0f];
        self.message .backgroundColor = [UIColor clearColor];
        //自动折行设置
        self.message.lineBreakMode = NSLineBreakByCharWrapping;
        self.message.numberOfLines = 0;
        [cell.contentView addSubview:self.message];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(268, 70, 50, 40)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.font =[UIFont systemFontOfSize:10.0f];
        self.timeLabel.textColor = [UIColor blueColor];
        [cell.contentView addSubview:self.timeLabel];
        self.timeImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"clock.png"]];
        [self.timeImage setFrame:CGRectMake(250, 83, 16, 16)];
        self.timeImage.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:self.timeImage];
        
        self.vote1Lable = [[UILabel alloc]initWithFrame:CGRectMake(110, 110, 40, 20)];
        self.vote1Lable.textColor = [UIColor redColor];
        self.vote1Lable.font = [UIFont fontWithName:@"Arial" size:12];
        self.vote1Lable.textAlignment = NSTextAlignmentCenter;
        self.vote1Lable.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:self.vote1Lable];
        
        self.oneImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.oneImageView setFrame:CGRectMake(5, 130, 150, 150)];
        [self.oneImageView setImage:[UIImage imageNamed:@"ph.png"] forState:UIControlStateNormal];
        //长按事件放大
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fangdaLeftClicked:)];
        longpress.minimumPressDuration = 0.5; //定义按的时间
        [self.oneImageView addGestureRecognizer:longpress];;
        [self.oneImageView addTarget:self action:@selector(buttonClickedLeft:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
        [self.oneImageView setTag:indexPath.row];
        [cell.contentView addSubview:self.oneImageView];
        
        self.vote2Lable = [[UILabel alloc]initWithFrame:CGRectMake(170, 110, 40, 20)];
        self.vote2Lable.textColor = [UIColor redColor];
        self.vote2Lable.font = [UIFont fontWithName:@"Arial" size:12];
        self.vote2Lable.textAlignment = NSTextAlignmentCenter;
        self.vote2Lable.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:self.vote2Lable];
        
        self.twoImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.twoImageView setFrame:CGRectMake(165, 130, 150, 150)];
        [self.twoImageView setImage:[UIImage imageNamed:@"ph.png"] forState:UIControlStateNormal];
        //长按事件放大
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fangdaRightClicked:)];
        longPress.minimumPressDuration = 0.5; //定义按的时间
        [self.twoImageView addGestureRecognizer:longPress];
        [self.twoImageView addTarget:self action:@selector(buttonClickedRight:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
        [self.twoImageView setTag:indexPath.row];
        [cell.contentView addSubview:self.twoImageView];
        
        commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentButton.tag = indexPath.row;
        [commentButton setTitle:@"评论" forState:UIControlStateNormal];
        [commentButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        commentButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        [commentButton setFrame:CGRectMake(5, 285, 50, 25)];
        [[commentButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[commentButton  layer] setBorderWidth:1];
        [[commentButton layer] setCornerRadius:8];
        [commentButton addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:commentButton];
        
        clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clickButton.tag = indexPath.row;
        [clickButton setTitle:@"查看投票" forState:UIControlStateNormal];
        [clickButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        clickButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        [clickButton setFrame:CGRectMake(190, 285, 70, 25)];
        [[clickButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[clickButton  layer] setBorderWidth:1];
        [[clickButton layer] setCornerRadius:8];
        [clickButton addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:clickButton];
        
        reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        reportButton.tag = indexPath.row;
        [reportButton setTitle:@"举报" forState:UIControlStateNormal];
        [reportButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        reportButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        [reportButton setFrame:CGRectMake(265, 285, 50, 25)];
        [[reportButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[reportButton  layer] setBorderWidth:1];
        [[reportButton layer] setCornerRadius:8];
        [reportButton addTarget:self action:@selector(reportButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:reportButton];
        
        selectOneImage = [[UIImageView alloc] initWithFrame:CGRectMake(115, 240, 40, 40)];
        [cell.contentView addSubview:selectOneImage];
        
        selectTwoImage = [[UIImageView alloc] initWithFrame:CGRectMake(275, 240, 40, 40)];
        [cell.contentView addSubview:selectTwoImage];
    }

}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isPush || isPushFromVotesGiven) {
        return  [votesArray count];
    }else{
         return [votesArray count]+1;
    }
}
- (void)displayVoteResults:(STreamObject *)so timeDiff:(NSString *)timeDiff
{
    ImageCache *cache = [ImageCache sharedObject];
    
    NSMutableDictionary *userMetadata = [cache getUserMetadata:[so getValue:@"userName"]];
    if (userMetadata){
        NSString *nickname = [userMetadata objectForKey:@"nickname"];
        if (!nickname)
            self.name.text = [so getValue:@"userName"];
        else
            self.name.text = nickname;
    }else{
        self.name.text = [so getValue:@"userName"];
    }
    
    self.timeLabel.text = timeDiff;
    
    VoteResults *vo = [cache getResults:[so objectId]];
    if (vo){
        self.vote1Lable.text = [vo f1];
        self.vote2Lable.text = [vo f2];
    }else{
        self.vote1Lable.text = @"0%";
        self.vote2Lable.text = @"0%";
    }
    if ([[vo f1] intValue]>= 50) {
        self.vote1Lable.textColor = [UIColor greenColor];
    }
    if ([[vo f2] intValue] >= 50) {
        self.vote2Lable.textColor = [UIColor greenColor];
    }
    
    STreamObject *voted = [loggedInUserVotesResults objectForKey:[so objectId]];
    if (voted != nil && [[voted objectId] isEqualToString:userNameToBeChecked]){
        NSString *voteResult = [voted getValue:[so objectId]];
        if ([voteResult isEqualToString: @"f1voted"]){
            selectOneImage.image = [UIImage imageNamed:@"tick.png"];
        }
        if ([voteResult isEqualToString: @"f2voted"]){
            selectTwoImage.image = [UIImage imageNamed:@"tick.png"];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        if ([votesArray count]-1 != indexPath.row) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 320,cell.frame.size.width , 10)];
            view.backgroundColor = [UIColor whiteColor];
            [cell.backgroundView addSubview:view];
        }
        [self createUIControls:cell withCellRowAtIndextPath:indexPath];
        
    }
    if (indexPath.row != [votesArray count]) {
        STreamObject *so = [votesArray objectAtIndex:indexPath.row];
        NSString *creationTimeStr = [so getValue:@"creationTime"];
        long lastModifiedTime = [creationTimeStr longLongValue];
        NSDate *now = [[NSDate alloc] init];
        long millionsSecs = [now timeIntervalSince1970];
        long diff = millionsSecs - lastModifiedTime;
        NSString *timeDiff = [self getTimeDiff:diff];
        NSString *message = [so getValue:@"message"];
        self.message.text = message;
        [self displayVoteResults:so timeDiff:timeDiff];
        [self downloadDoubleImage:so];
        [self loadUserMetadataAndDownloadUserProfileImage:so];
    }
    return cell;
}

//comments button
-(void)commentButtonClicked:(UIButton *)button
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [self tableView:self.myTableView];
    }
    ImageCache * cache = [ImageCache sharedObject];
    if ([cache getLoginUserName]){
        CommentsViewController *commentsView = [[CommentsViewController alloc]init];
        [commentsView setRowObject:[votesArray objectAtIndex:button.tag]];
        commentsView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:commentsView animated:YES];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您还没有登录，请先登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"登录", nil];
        alertView.delegate = self;
        [alertView show];
    }
    
}

//reportButtonClicked
-(void)reportButtonClicked:(UIButton *)button{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [self tableView:self.myTableView];
    }
    tag = button.tag;
    isReport = YES;
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您确定要举报此信息？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.delegate = self;
    [alertView show];

}

//查看投票
-(void)clickedButton:(UIButton *)sender
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [self tableView:self.myTableView];
    }
    ImageCache * cache = [ImageCache sharedObject];
    if ([cache getLoginUserName]) {
        VotesShowViewController *votesView = [[VotesShowViewController alloc]init];
        [votesView setRowObject:[votesArray objectAtIndex:sender.tag]];
        [self.navigationController pushViewController:votesView animated:YES];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您还没有登录，请先登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"登录", nil];
        alertView.delegate = self;
        [alertView show];
    }
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (isReport) {
        if (buttonIndex == 1){
            STreamObject *so = [votesArray objectAtIndex:tag];
            [so setCategory:@"Reports"];
            [so updateInBackground];
        }
        isReport = NO;
    }else{
        if (buttonIndex == 1){
            [APPDELEGATE showLoginView];
        }
    }
   
}

- (void)downloadDoubleImage: (STreamObject *)so{
  
    ImageCache *imageCache = [ImageCache sharedObject];
    
    NSString *file1 = [so getValue:@"file1"];
    NSString *file2 = [so getValue:@"file2"];
    NSData *fData1 = [imageCache getImage:file1];
    NSData *fData2 = [imageCache getImage:file2];
    
    if (fData1){
        [self.oneImageView setImage:[UIImage imageWithData:fData1] forState:UIControlStateNormal];
        [oneImageViewActivity stopAnimating];
    }else{
        ImageDownload *imageDownload = [[ImageDownload alloc] init];
        [imageDownload downloadFile:file1];
        [imageDownload setMainRefesh:self];
    }
    
    if (fData2){
        [self.twoImageView setImage:[UIImage imageWithData:fData2] forState:UIControlStateNormal];
        [twoImageViewActivity stopAnimating];
    }else{
        ImageDownload *imageDownload = [[ImageDownload alloc] init];
        [imageDownload downloadFile:file2];
        [imageDownload setMainRefesh:self];
    }
 
}

- (void)loadUserMetadataAndDownloadUserProfileImage : (STreamObject *) so{
    
    ImageCache *imageCache = [ImageCache sharedObject];

    NSString *currentRowUserName = [so getValue:@"userName"];
    //load user metadata and profile image
    if ([imageCache getUserMetadata:currentRowUserName] != nil){
        NSMutableDictionary *userMetaData = [imageCache getUserMetadata:currentRowUserName];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if ([imageCache getImage:pImageId] == nil && pImageId){
            ImageDownload *imageDownload = [[ImageDownload alloc] init];
            [imageDownload downloadFile:pImageId];
        }else{
            if (pImageId)
                [self.imageView setImage:[UIImage imageWithData:[imageCache getImage:pImageId]] forState:UIControlStateNormal];
        }
        [imageViewActivity stopAnimating];
    }else{
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:currentRowUserName response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:currentRowUserName]){
                NSMutableDictionary *dic = [user userMetadata];
                [imageCache saveUserMetadata:currentRowUserName withMetadata:dic];
            }
        }];
    }

}
-(void) loadResultVotes:(UIButton *)button{
    ImageCache *imageCache = [ImageCache sharedObject];
    STreamQuery *sqq = [[STreamQuery alloc] initWithCategory:@"Voted"];
    [sqq setQueryLogicAnd:FALSE];
    NSString *objectId  = [[votesArray objectAtIndex:button.tag] objectId];
    NSMutableArray * leftVoters= [[NSMutableArray alloc]init];
    NSMutableArray * rightVoters= [[NSMutableArray alloc]init];
    [sqq whereEqualsTo:objectId forValue:@"f1voted"];
    [sqq whereEqualsTo:objectId forValue:@"f2voted"];
     NSMutableArray *result = [sqq find];
    if (result && [result count] > 0){
        for (STreamObject *so in result){
            NSString *vote = [so getValue:objectId];
            if ([vote isEqualToString:@"f1voted"])
                [leftVoters addObject:[so objectId]];
            if ([vote isEqualToString:@"f2voted"])
                [rightVoters addObject:[so objectId]];
        }
        int leftCount = [leftVoters count];
        int rightCount = [rightVoters count];
        
        int total = [leftVoters count] + [rightVoters count];
        
        int vote1count = ((float)leftCount/total)*100;
        int vote2count = ((float)rightCount/total)*100;
        
        NSString *vote1 = [NSString stringWithFormat:@"%d%%",vote1count];
        NSString *vote2 = [NSString stringWithFormat:@"%d%%",vote2count];
        VoteResults *vo = [[VoteResults alloc] init];
        [vo setObjectId:[[votesArray objectAtIndex:button.tag] objectId]];
        [vo setF1:vote1];
        [vo setF2:vote2];
        [imageCache addVotesResults:[[votesArray objectAtIndex:button.tag] objectId] withVoteResult:vo];
    }
    [self.myTableView reloadData];

}
-(void)voteTheTopicLeft:(UIButton *)button{
    
    STreamQuery *sq = [[STreamQuery alloc] initWithCategory:@"Voted"];
    ImageCache *cache = [ImageCache sharedObject];
    [sq addLimitId:[cache getLoginUserName]];
    NSMutableArray *vote = [sq find];//block
    if ([vote count] > 0){
        
        STreamObject *so = [vote objectAtIndex:0];
        STreamObject *sorow = [votesArray objectAtIndex:button.tag];
        NSString *votedKey = [so getValue:[sorow objectId]];
        
        if (votedKey == nil){
            
            //update category voted
            [so addStaff:[sorow objectId] withObject:@"f1voted"];
            [so update];
            NSString *error = [so errorMessage];
            NSLog(@"error: %@", error);
            [loggedInUserVotesResults setObject:so forKey:[sorow objectId]];
            
        }else if([votedKey isEqualToString:@"f1voted"]){
          
            //update category voted
            [so removeKey:[sorow objectId] forObjectId:[so objectId]];
            NSString *error = [so errorMessage];
            NSLog(@"error: %@", error);
            [loggedInUserVotesResults removeObjectForKey:[sorow objectId]];
            
        }else{
            
            //update category voted
            [so removeKey:[sorow objectId] forObjectId:[so objectId]];
            NSString *error = [so errorMessage];
            NSLog(@"error: %@", error);
            [so addStaff:[sorow objectId] withObject:@"f1voted"];
            [so update];
            error = [so errorMessage];
            NSLog(@"error: %@", error);
            [loggedInUserVotesResults setObject:so forKey:[sorow objectId]];
            
        }
    }
//    [self clickedButton:button];
    [self loadResultVotes:button];
    
}

-(void)buttonClickedLeft:(UIButton *)button withEvent:(UIEvent*)event {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [self tableView:self.myTableView];
    }
    UITouch* touch = [[event allTouches] anyObject];
    ImageCache * cache = [[ImageCache alloc]init];
    if ([cache getLoginUserName]) {
        if (touch.tapCount == 2) {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"投票中...";
            [self.view addSubview:HUD];
            [HUD showWhileExecuting:@selector(voteTheTopicLeft:) onTarget:self withObject:button animated:YES];
        }
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您还没有登录，请先登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"登录", nil];
        [alertView show];
    }
}

-(void)voteTheTopicRight:(UIButton *)button{
    
    STreamQuery *sq = [[STreamQuery alloc] initWithCategory:@"Voted"];
    ImageCache *cache = [ImageCache sharedObject];
    [sq addLimitId:[cache getLoginUserName]];
    NSMutableArray *vote = [sq find];
    if ([vote count] > 0){
        
        STreamObject *so = [vote objectAtIndex:0];
        STreamObject *sorow = [votesArray objectAtIndex:button.tag];
        NSString *votedKey = [so getValue:[sorow objectId]];
        
        if (votedKey == nil){
            //update category voted
            [so addStaff:[sorow objectId] withObject:@"f2voted"];
            [so update];
            NSString *error = [so errorMessage];
            NSLog(@"error: %@", error);
            [loggedInUserVotesResults setObject:so forKey:[sorow objectId]];
        }
        
        else if([votedKey isEqualToString:@"f2voted"]){
            //update category voted
            [so removeKey:[sorow objectId] forObjectId:[so objectId]];
            NSString *error = [so errorMessage];
            NSLog(@"error: %@", error);
            [loggedInUserVotesResults removeObjectForKey:[sorow objectId]];
            
        }else{
            
            //update category voted
            [so removeKey:[sorow objectId] forObjectId:[so objectId]];
            NSString *error = [so errorMessage];
            NSLog(@"error: %@", error);
            [so addStaff:[sorow objectId] withObject:@"f2voted"];
            [so update];
            error = [so errorMessage];
            NSLog(@"error: %@", error);
            [loggedInUserVotesResults setObject:so forKey:[sorow objectId]];
        }

    }

//    [self clickedButton:button];
    [self loadResultVotes:button];
}

-(void)buttonClickedRight:(UIButton *)button withEvent:(UIEvent*)event {
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [self tableView:self.myTableView];
    }
    UITouch* touch = [[event allTouches] anyObject];
    ImageCache * cache = [ImageCache sharedObject];
    if ([cache getLoginUserName]) {
        if (touch.tapCount == 2) {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"投票中...";
            [self.view addSubview:HUD];
            [HUD showWhileExecuting:@selector(voteTheTopicRight:) onTarget:self withObject:button animated:YES];
        }

    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您还没有登录，请先登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"登录", nil];
        [alertView show];
    }

}
- (void)reloadTable{
   [self.myTableView reloadData];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [votesArray count]) {
        return 44;
    }else{
        return 330;
    }
    
}
-(void)tableView:(UITableView *)tableView
{
    [_fullScreenDelegate showUIBarsWithScrollView:tableView animated:YES];
}
//head image clicked
-(void) headImageClicked:(UIButton *)sender {
    [self tableView:self.myTableView];
    ImageCache * cache = [[ImageCache alloc]init];
    if ([cache getLoginUserName]){
        STreamObject *so = [votesArray objectAtIndex:sender.tag];
        InformationViewController *informationView = [[InformationViewController alloc]init];
        informationView.userName = [so getValue:@"userName"];
        informationView.isPush = YES;
        [self.navigationController pushViewController:informationView animated:YES];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您还没有登录，请先登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"登录", nil];
        [alertView show];
    }
}

//fangda
-(void)fangdaLeftClicked:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIButton *btn = (UIButton*)gestureRecognizer.view;
        [self fangda:btn];
    }
}
-(void)fangdaRightClicked:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        isRight = YES;
        UIButton *btn = (UIButton*)gestureRecognizer.view;
        [self fangda:btn];
    }
    
}
- (void)fangda:(UIButton *)button
{
    //创建灰色透明背景，使其背后内容不可操作
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    background = bgView;
    [bgView setBackgroundColor:[UIColor colorWithRed:0.3
                                               green:0.3
                                                blue:0.3
                                               alpha:0.7]];
    [self.view addSubview:bgView];
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
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, BIG_IMG_WIDTH, BIG_IMG_HEIGHT)];
    if (isRight) {
        [imgview setImage: button.imageView.image];
    }else{
        [imgview setImage: button.imageView.image];
    }
    [borderView addSubview:imgview];
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

#pragma mark Full Screen
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // hide tabBar when pushed & show again when popped
    self.hidesBottomBarWhenPushed = YES;
    
    double delayInSeconds = UINavigationControllerHideShowBarDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.hidesBottomBarWhenPushed = NO;
    });
}
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_fullScreenDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_fullScreenDelegate scrollViewDidScroll:scrollView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return [_fullScreenDelegate scrollViewShouldScrollToTop:scrollView];;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [_fullScreenDelegate scrollViewDidScrollToTop:scrollView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
