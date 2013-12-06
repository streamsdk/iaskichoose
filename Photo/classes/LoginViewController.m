 //
//  LoginViewController.m
//  Photo
//
//  Created by wangshuai on 13-9-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "LoginViewController.h"
#import "PhotoViewController.h"
#import "RegisterViewController.h"
#import "MainViewController.h"
#import <arcstreamsdk/STreamUser.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UserInformationViewController.h"
#import "InformationViewController.h"
#import "FireViewController.h"
#import "ImageCache.h"
#import "UserDB.h"


@interface LoginViewController ()
{
    MBProgressHUD *HUD;
    STreamUser *user;
//    NSMutableArray *dataArray;
}
@end

@implementation LoginViewController
@synthesize name = _name;
@synthesize password =_password;
@synthesize loginButton = _loginButton;
@synthesize registerButton = _registerButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(NSString *)dataFilePath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:KFilename];
}
-(void)backlicked{
    ImageCache * cache = [[ImageCache alloc]init];
    if ([cache getLoginUserName]) {
        [APPDELEGATE showLoginSucceedView];
    }else{
        [APPDELEGATE showMainView];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.name becomeFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //test commit from second edward
    self.title = @"登录";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backlicked)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UITextField *text = [[UITextField alloc]initWithFrame:CGRectMake(30, 10, 260, 50)];
    text.enabled = NO;
    [self.view addSubview:text];
    
     if ([[[UIDevice currentDevice] systemVersion] floatValue]< 7.0) {
         
         self.name = [[UITextField alloc]initWithFrame:CGRectMake(30, 30, 260, 50)];
         self.password = [[UITextField alloc]initWithFrame:CGRectMake(30, 90, 260, 50)];
         [self.loginButton setFrame:CGRectMake(30, 150, 120, 40)];
         [self.registerButton setFrame:CGRectMake(170, 150, 120,40)];
     }else{
         self.name = [[UITextField alloc]initWithFrame:CGRectMake(30, 70, 260, 50)];
         self.password = [[UITextField alloc]initWithFrame:CGRectMake(30, 130, 260, 50)];
         [self.loginButton setFrame:CGRectMake(30, 220, 120, 40)];
         [self.registerButton setFrame:CGRectMake(170, 220, 120,40)];
     }
    
    
    self.name.placeholder=@"登录名";
    self.name.borderStyle = UITextBorderStyleRoundedRect;
    self.name.contentVerticalAlignment= UIControlContentVerticalAlignmentCenter;
    self.name.autocorrectionType = UITextAutocorrectionTypeYes;
    self.name.delegate =self;
    [self.view addSubview: self.name];
    
    
    self.password.placeholder=@"密码";
    self.password.borderStyle = UITextBorderStyleRoundedRect;
    [self.password setSecureTextEntry:YES];
    self.password.contentVerticalAlignment= UIControlContentVerticalAlignmentCenter;
    self.password.delegate =self;
    [self.view addSubview: self.password];
    //loginbutton 
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [[self.loginButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[self.loginButton  layer] setBorderWidth:1];
    [[self.loginButton layer] setCornerRadius:8];
    [self.view addSubview:self.loginButton];
    
    //注册 registerButton
    [[self.registerButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[self.registerButton  layer] setBorderWidth:1];
    [[self.registerButton layer] setCornerRadius:8];
    [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];

}
//loginButton
-(void)loginButtonClicked{
    
    if (([self.name.text length]==0) && ([self.password.text length]==0)) {
        
        UIAlertView * view = [[UIAlertView alloc]initWithTitle:nil message:@"用户名和密码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
        
    }else{
        
        
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.labelText = @"登录中...";
        [self.view addSubview:HUD];
        user = [[STreamUser alloc] init];
        
       // UserDB *userDB = [[UserDB alloc] init];
       // [userDB logout];
        
        ImageCache *cache = [ImageCache sharedObject];
        
        [cache setLoginUserName:_name.text];
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self loginUser];
        } completionBlock:^{
           if ([[user errorMessage] length] == 0) {
               [APPDELEGATE showLoginSucceedView];
            }else{
               UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"错误信息" message:@"用户不存在或密码不匹配，请先注册，谢谢" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertview show];
            }
            [HUD removeFromSuperview];
            HUD = nil;
        }];
    }
    
}
-(void)loginUser
{
    [user logIn:self.name.text withPassword:self.password.text];
    UserDB *userDB = [[UserDB alloc] init];
    [userDB insertDB:0 name:self.name.text withPassword:self.password.text];
    
}

//registerButtonClicked
-(void)registerButtonClicked{
    
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    [self.navigationController pushViewController:registerVC animated:YES];
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
}
//UITextFied
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.name resignFirstResponder];
    [self.password resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
