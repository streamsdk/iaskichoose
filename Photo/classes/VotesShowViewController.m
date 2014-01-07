//
//  VotesShowViewController.m
//  Photo
//
//  Created by wangsh on 13-9-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "VotesShowViewController.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamUser.h>
#import "ImageCache.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "ImageDownload.h"
#import "InformationViewController.h"
#import "CommentsViewController.h"


@interface VotesShowViewController (){
    NSMutableArray *result;
    NSMutableArray *leftVoters;
    NSMutableArray *rightVoters;
    NSString *leftImageId;
    NSString *rightImageId;
    int vote1count;
    int vote2count;
    UIView *cellView;
}

@end

@implementation VotesShowViewController

@synthesize countLable;
@synthesize vote1Lable;
@synthesize vote2Lable;
@synthesize leftButton;
@synthesize rightButton;
@synthesize oneImageView;
@synthesize twoImageView;
@synthesize rowObject;
@synthesize leftImage;
@synthesize rightImage;

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
 
    self.title = @"投票";
    leftImageId = [rowObject getValue:@"file1"];
    rightImageId = [rowObject getValue:@"file2"];
    
    leftVoters = [[NSMutableArray alloc] init];
    rightVoters = [[NSMutableArray alloc] init];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"读取中...";
    [self.view addSubview:HUD];
    
   // [HUD showWhileExecuting:@selector(loadVotes) onTarget:self withObject:nil animated:YES];
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadVotes];
    }completionBlock:^{
         [self.tableView reloadData];
         HUD = nil;
    }];
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:self.tableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    self.tableView.backgroundView = backgrdView;
}
- (void)loadVotes{

    ImageCache*imageCache = [ImageCache sharedObject];
    STreamQuery *sqq = [[STreamQuery alloc] initWithCategory:@"Voted"];
    [sqq setQueryLogicAnd:FALSE];
    NSString *objectId  = [rowObject objectId];
    
    [sqq whereEqualsTo:objectId forValue:@"f1voted"];
    [sqq whereEqualsTo:objectId forValue:@"f2voted"];
    result = [sqq find];
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
        
        vote1count = ((float)leftCount/total)*100;
        vote2count = ((float)rightCount/total)*100;
        
        NSString *vote1 = [NSString stringWithFormat:@"%d%%",vote1count];
        NSString *vote2 = [NSString stringWithFormat:@"%d%%",vote2count];
        VoteResults *vo = [[VoteResults alloc] init];
        [vo setObjectId:[rowObject objectId]];
        [vo setF1:vote1];
        [vo setF2:vote2];
        [imageCache addVotesResults:[rowObject objectId] withVoteResult:vo];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//创建cell上控件
-(void)createUIControls:(UITableViewCell *)cell withCellRowAtIndextPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
    
        cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 190)];
        self.vote1Lable = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 80, 40)];
        self.vote1Lable.textColor = [UIColor redColor];
        self.vote1Lable.font = [UIFont fontWithName:@"Arial" size:14];
        self.vote1Lable.backgroundColor = [UIColor clearColor];
        [cellView addSubview:self.vote1Lable];
        
        self.oneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 40, 150, 150)];
        [self.oneImageView setImage:[UIImage imageNamed:@"headImage.jpg"] ];
        [cellView addSubview:self.oneImageView];
        
        
        self.vote2Lable = [[UILabel alloc]initWithFrame:CGRectMake(230, 0, 80, 40)];
        self.vote2Lable.textColor = [UIColor greenColor];
        self.vote2Lable.font = [UIFont fontWithName:@"Arial" size:14];
        self.vote2Lable.textAlignment = NSTextAlignmentRight;
        self.vote2Lable.backgroundColor = [UIColor clearColor];
        [cellView addSubview:self.vote2Lable];
        
        self.twoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(165, 40, 150, 150)];
        [self.twoImageView setImage:[UIImage imageNamed:@"headImage.jpg"] ];
        [cellView addSubview:self.twoImageView];
        
        
        self.countLable = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 100, 40)];
        self.countLable.textColor = [UIColor blackColor];
        self.countLable.textAlignment = NSTextAlignmentCenter;
        self.countLable.font = [UIFont fontWithName:@"Arial" size:16];
        self.countLable.textAlignment = NSTextAlignmentCenter;
        self.countLable.backgroundColor = [UIColor clearColor];
        [cellView addSubview:self.countLable];
        [cell addSubview:cellView];
        
    }else{
        UIImageView *imageview  = [[UIImageView alloc]initWithFrame:CGRectMake(159, 0, 2, 50)];
        imageview.image = [UIImage imageNamed:@"line.png"];
        [cell addSubview:imageview];
        self.leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2, 40, 40)];
        [cell.contentView addSubview:self.leftImage];
        
        self.leftButton = [[UIButton alloc]initWithFrame:CGRectMake(40, 2, 120,40)];
        self.leftButton.titleLabel.font =[UIFont fontWithName:@"Arial" size:12];
        [self.leftButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.leftButton];
        
        self.rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(280, 2, 40, 40)];
        [cell.contentView addSubview:self.rightImage];
        self.rightButton = [[UIButton alloc]initWithFrame:CGRectMake(160, 2, 120,40)];
        self.rightButton.titleLabel.font =[UIFont fontWithName:@"Arial" size:12];
        [self.rightButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.rightButton];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [leftVoters count] > [rightVoters count] ? [leftVoters count] + 1 : [rightVoters count] + 1;
}


- (void)loadUserMetadata:(NSString *)userName withImage:(UIImageView *)image{
    
    ImageCache *cache = [ImageCache sharedObject];
    NSMutableDictionary *userMetaData = [cache getUserMetadata:userName];
    
    if (userMetaData){
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if (pImageId && ![cache getImage:pImageId]){
            ImageDownload *imageDownload = [[ImageDownload alloc] init];
            [imageDownload downloadFile:pImageId];
            [image setImage:[UIImage imageNamed:@"headImage.jpg"]];
        }else{
           if (pImageId)
               [image setImage:[UIImage imageWithData:[cache getImage:pImageId]]];
        }
        
    }else{
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:userName response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:userName]){
                NSMutableDictionary *dic = [user userMetadata];
                [cache saveUserMetadata:userName withMetadata:dic];
            }
        }];
        [image setImage:[UIImage imageNamed:@"headImage.jpg"]];
    }

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
       
        [self createUIControls:cell withCellRowAtIndextPath:indexPath];
    }
    ImageCache *cache = [ImageCache sharedObject];

    self.vote1Lable.text=[NSString stringWithFormat:@"%d%%",vote1count];
    self.vote2Lable.text=[NSString stringWithFormat:@"%d%%",vote2count];
    
    if (indexPath.row != 0) {
        if ([leftVoters count]!=0 && [leftVoters count] - 1 >= (indexPath.row - 1)){
            [self.leftButton setTitle:[leftVoters objectAtIndex:(indexPath.row-1 )] forState:UIControlStateNormal];
            [self loadUserMetadata:[leftVoters objectAtIndex:(indexPath.row-1 )] withImage:leftImage];
        }
        if ([rightVoters count]!=0 &&[rightVoters count] - 1 >= (indexPath.row - 1)){
            [self.rightButton setTitle:[rightVoters objectAtIndex:(indexPath.row-1 )] forState:UIControlStateNormal];
            [self loadUserMetadata:[rightVoters objectAtIndex:(indexPath.row-1 )] withImage:rightImage];
        }
}
   
    NSString *file1 = [rowObject getValue:@"file1"];
    NSString *file2 = [rowObject getValue:@"file2"];
    self.oneImageView.image = [UIImage imageWithData:[cache getImage:file1]];
    self.twoImageView.image = [UIImage imageWithData:[cache getImage:file2]];
    self.countLable.text=[NSString stringWithFormat:@"投票数:%d", [result count]];
    return cell;
}
- (void)reloadTable{
    [self.tableView reloadData];
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 230;
    }else{
        return 44;
    }
}
//
-(void)buttonClicked:(UIButton *)button{
    InformationViewController * informationVC = [[InformationViewController alloc]init];
    informationVC.userName = button.titleLabel.text;
    informationVC.isPush = YES;
    [self.navigationController pushViewController:informationVC animated:YES];
}
@end
