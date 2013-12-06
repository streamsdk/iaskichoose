//
//  VotesShowViewController.h
//  Photo
//
//  Created by wangsh on 13-9-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <arcstreamsdk/STreamObject.h>
#import "MainViewTableViewRfresh.h"
@interface VotesShowViewController : UITableViewController<MainViewTableViewRfresh>
{
    
}
@property (strong,nonatomic) UILabel *countLable;
@property (strong,nonatomic) UILabel *vote1Lable;
@property (strong,nonatomic) UILabel *vote2Lable;
@property (strong,nonatomic) UIImageView *oneImageView;
@property (strong,nonatomic) UIImageView *twoImageView;
@property (strong,nonatomic) UIButton *leftButton;
@property (strong,nonatomic) UIButton *rightButton;
@property (strong,nonatomic) UIImageView *leftImage;
@property (strong,nonatomic) UIImageView *rightImage;
@property (strong,nonatomic) STreamObject *rowObject;
@end
