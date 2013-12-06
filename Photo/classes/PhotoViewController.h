//
//  PhotoViewController.h
//  Photo
//
//  Created by wangshuai on 13-9-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectMessageP.h"

@interface PhotoViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,SelectMessageP, UIAlertViewDelegate>
{
    
}
@property (strong ,nonatomic) UIImageView * imageView2;
@property (strong ,nonatomic) UIImageView * imageView;
@property (strong ,nonatomic) UIImagePickerController *imagePicker;
@property (strong ,nonatomic) UITextView *message;
@property (strong ,nonatomic) UITableView *myTableView;
@property (strong ,nonatomic) UIButton *registerButton;
@property (copy,nonatomic) NSString *messages;
@end
