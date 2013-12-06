//
//  LoginViewController.h
//  Photo
//
//  Created by wangshuai on 13-9-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>


#define KFilename @"data.plist"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
{

    NSMutableArray *listData;

}
@property (retain,nonatomic) UITextField *name;
@property (retain,nonatomic) UITextField *password;
@property (retain,nonatomic) UIButton *loginButton;
@property (retain,nonatomic) UIButton *registerButton;
@end
