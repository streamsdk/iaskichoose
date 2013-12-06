//
//  CommentsViewController.h
//  Photo
//
//  Created by wangsh on 13-9-26.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <arcstreamsdk/STreamObject.h>

@interface CommentsViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate>
{
    UITableView *myTableView;
}

@property (strong,nonatomic) UIImageView *oneImageView;
@property (strong,nonatomic) UIImageView *twoImageView;
@property (strong,nonatomic) UIImageView *headImageView;
@property (strong,nonatomic) UITextView *contentView;
@property (strong,nonatomic) UILabel *nameLable;
@property (strong,nonatomic) STreamObject *rowObject;
@property (strong,nonatomic) UILabel * messageLabel;
@end
