//
//  FireViewController.h
//  Photo
//
//  Created by wangsh on 13-9-29.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewTableViewRfresh.h"

@interface FireViewController : UITableViewController<MainViewTableViewRfresh>

@property (strong,nonatomic) UIView *leftView;
@property (strong,nonatomic) UIView *rightView;
@property (strong,nonatomic) UIButton *firstLeftButton;
@property (strong,nonatomic) UIButton *firstRightButton;
@property (strong,nonatomic) UIButton *secondLeftButton;
@property (strong,nonatomic) UIButton *secondRightButton;

@end
