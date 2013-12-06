//
//  MainViewController.h
//  Photo
//
//  Created by wangshuai on 13-9-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewTableViewRfresh.h"
#import "SelectMessageP.h"

@interface MainViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, MainViewTableViewRfresh,UITextViewDelegate>
{
    NSMutableArray *votesArray;
}

@property (retain,nonatomic) UITableView *myTableView ;

@property (strong ,nonatomic) UIButton *imageView;
@property (strong,nonatomic) UITextField *name;
@property (strong,nonatomic) UILabel *message;
@property (strong,nonatomic) UILabel *vote1Lable;
@property (strong,nonatomic) UILabel *vote2Lable;
@property (strong,nonatomic) UILabel *timeLabel;
@property (strong,nonatomic) UIImageView *timeImage;
@property (strong,nonatomic) UIButton *oneImageView;
@property (strong,nonatomic) UIButton *twoImageView;
@property (strong,nonatomic) UIButton *clickButton;
@property (strong,nonatomic) UIButton *commentButton;
@property (strong,nonatomic) UIButton *reportButton;
@property (strong,nonatomic) NSMutableArray *votesArray;
@property (assign)BOOL isPush;
@property (assign)BOOL isPushFromVotesGiven;
@property (strong,nonatomic) NSString * userName;
@property (strong,nonatomic) UIImageView *selectOneImage;
@property (strong,nonatomic) UIImageView *selectTwoImage;

@property (strong,nonatomic) UIButton *loadMoreButton;
@end
