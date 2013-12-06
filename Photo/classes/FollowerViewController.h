//
//  FollowerViewController.h
//  Photo
//
//  Created by wangsh on 13-9-27.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowerViewController : UITableViewController

@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UILabel  *nameLabel;
@property (strong,nonatomic) UIButton *followerButton;
@property (retain,nonatomic) NSArray *followerArray;
@property (retain,nonatomic) NSString *userName;
@end
