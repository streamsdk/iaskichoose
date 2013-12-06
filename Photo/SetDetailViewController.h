//
//  SetDetailViewController.h
//  Photo
//
//  Created by wangsh on 13-10-10.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetDetailViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (copy ,nonatomic) NSString *string;
@property (strong,nonatomic) UITextField *nameTextFied;
@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *passworLabel;
@property (strong,nonatomic) UITextField *passwordTextFied;
@property (strong,nonatomic) UILabel *repassworLabel;
@property (strong,nonatomic) UITextField *repasswordTextFied;
@property (strong,nonatomic) UIImageView *headImage;
@property (strong,nonatomic) UIButton *doneButton;
@end
