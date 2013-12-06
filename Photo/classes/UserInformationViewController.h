//
//  UserInformationViewController.h
//  Photo
//
//  Created by wangsh on 13-9-28.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInformationViewController : UITableViewController

@property (strong,nonatomic) UIImageView *headImage;
@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *votesLabel;
@property (strong,nonatomic) UIButton *followButton;



@end
