//
//  FollowingViewController.h
//  Photo
//
//  Created by wangsh on 13-9-27.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowingViewController : UITableViewController

@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UILabel  *nameLabel;
@property (strong,nonatomic) UIButton *followingButton;
@property (retain,nonatomic) NSString *userName;
@end
