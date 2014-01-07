//
//  RegisterViewController.m
//  Photo
//
//  Created by wangshuai on 13-9-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamFile.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "UserDB.h"
#import "ServiceAgreementViewController.h"

@interface RegisterViewController ()
{
    BOOL isAddImage;
    UIAlertView *alertview;
    bool picked;
    BOOL isClicked;
}
@end

@implementation RegisterViewController
@synthesize nameText = _nameText;
@synthesize passwordText = _passwordText;
@synthesize rePassword = _rePassword;
@synthesize registerButton = _registerButton;
@synthesize genderArray = _genderArray;
@synthesize imageview =_imageview;
@synthesize myTableView = _myTableView;
@synthesize actionSheet = _actionSheet;
@synthesize nicknameText;
@synthesize selectButton;
@synthesize seleclabel;
@synthesize serviceAgreementButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    isClicked = YES;
    self.title = @"注册";
    self.genderArray = [[NSArray alloc]initWithObjects:@"--选择性别--",@"男",@"女", nil];
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    self.myTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.myTableView];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.separatorStyle=NO;//UITableView每个cell之间的默认分割线隐藏掉
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:_myTableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    _myTableView.backgroundView = backgrdView;
    
    // 建立 UIDatePicker
    datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, -(self.view.bounds.size.height), self.view.bounds.size.width, 100)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    datePicker.locale = datelocale;
    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    // 建立 UIToolbar
    toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0, 320, 44)];
     UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelPicker)];
    toolBar.items = [NSArray arrayWithObject:right];

}
#pragma mark-------------tableView-------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellName =@"CellID";
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        
        self.imageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-120)/2, 10, 120, 120)];
        self.imageview.userInteractionEnabled = YES;
        self.imageview.image = [UIImage imageNamed:@"profile1.png"];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)];
        [ self.imageview  addGestureRecognizer:singleTap];
        [cell.contentView addSubview:self.imageview];
        
        self.nameText = [[UITextField alloc]initWithFrame:CGRectMake(20, 140, self.view.frame.size.width - 40, 50)];
        self.nameText.placeholder = @"登录名";
        self.nameText.keyboardType = UIKeyboardTypeASCIICapable;
        self.nameText.borderStyle = UITextBorderStyleRoundedRect;
        self.nameText.delegate = self;
        [cell.contentView addSubview:self.nameText];
        
        self.passwordText = [[UITextField alloc]initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40,50)];
        self.passwordText.placeholder = @"密码";
        self.passwordText.borderStyle =UITextBorderStyleRoundedRect;
        self.passwordText.delegate = self;
        [self.passwordText setSecureTextEntry:YES];//
        [cell.contentView addSubview:self.passwordText];
        
        self.rePassword = [[UITextField alloc]initWithFrame:CGRectMake(20, 260, self.view.frame.size.width - 40, 50)];
        self.rePassword.placeholder = @"确认密码";
        self.rePassword.borderStyle = UITextBorderStyleRoundedRect;
        [self.rePassword setSecureTextEntry:YES];
        self.rePassword.delegate = self;
        [cell.contentView addSubview:self.rePassword];
        
        self.nicknameText = [[UITextField alloc]initWithFrame:CGRectMake(20, 320, self.view.frame.size.width - 40, 50)];
        self.nicknameText.placeholder = @"昵称";
        self.nicknameText.borderStyle = UITextBorderStyleRoundedRect;
        self.nicknameText.delegate = self;
        [cell.contentView addSubview:self.nicknameText];
        
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[self.selectButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[self.selectButton  layer] setBorderWidth:1];
        [[self.selectButton layer] setCornerRadius:8];
        [self.selectButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.selectButton setFrame:CGRectMake(20, 390,20, 20)];
        [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.selectButton];
        
        seleclabel = [[UILabel alloc]initWithFrame:CGRectMake(50,390, 144, 20)];
        seleclabel.text = @"我年龄在17岁以上我已经阅读了";
        seleclabel.backgroundColor = [UIColor clearColor];
        seleclabel.font = [UIFont systemFontOfSize:10.0f];
        [cell addSubview:seleclabel];
        
        serviceAgreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [serviceAgreementButton setFrame:CGRectMake(188,390,80,21)];
        serviceAgreementButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [serviceAgreementButton setTitle:@"用户协议(EULA)" forState:UIControlStateNormal];
        [serviceAgreementButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        serviceAgreementButton.titleLabel.font =[UIFont systemFontOfSize:10.0f];
        [serviceAgreementButton addTarget:self action:@selector(serviceAgreementClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:serviceAgreementButton];

        self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[self.registerButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[self.registerButton  layer] setBorderWidth:1];
        [[self.registerButton layer] setCornerRadius:8];
        [self.registerButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.registerButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.registerButton setFrame:CGRectMake(20, 440, self.view.frame.size.width - 40, 40)];
        [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [self.registerButton addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.registerButton];
}
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _myTableView.bounds.size.height+180;
}
//serviceAgreementClicked
-(void)serviceAgreementClicked:(UIButton *)button {
    
    ServiceAgreementViewController * serviceVC =[[ServiceAgreementViewController alloc]init];
    [self.navigationController pushViewController:serviceVC animated:YES];
}
//selectButtonClicked
-(void)selectButtonClicked:(UIButton *)button{
    if (YES == isClicked) {
        [button setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
        isClicked = NO;
    }else{
        [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        isClicked = YES;
    }
    
}
//registerButton
-(void) registerClicked:(UIButton *)button {
    if (isClicked) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"您必须同意该服务协议" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        if ([self.passwordText.text isEqualToString:self.rePassword.text] && ([self.nameText.text length]!= 0)) {
            __block  MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"注册中...";
            [self.view addSubview:HUD];
            
            [HUD showAnimated:YES whileExecutingBlock:^{
                [self registerUser];
            } completionBlock:^{
                [HUD removeFromSuperview];
                HUD=nil;
                [APPDELEGATE showLoginSucceedView];
            }];
            
        }else{
            alertview = [[UIAlertView alloc]initWithTitle:@"Error" message:@"两次输入密码不同，请重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:YES];
            [alertview show];
        }
    }
}

-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)registerUser{
    
    STreamFile *file = [[STreamFile alloc] init];
    
    UIImage *sImage = [self imageWithImageSimple:self.imageview.image scaledToSize:CGSizeMake(300.0, 300.0)];
    NSData *postData = UIImageJPEGRepresentation(sImage, 0.1);
    if (picked){
        [file postData:postData];
        sleep(1);
    }
    
    STreamUser *user = [[STreamUser alloc] init];
    NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
    [metaData setValue:self.nameText.text forKey:@"name"];
    [metaData setValue:self.passwordText.text forKey:@"password"];
    [metaData setValue:self.nicknameText.text forKey:@"nickname"];
    if ([[file errorMessage] isEqualToString:@""] && [file fileId])
        [metaData setValue:[file fileId] forKey:@"profileImageId"];
    [user signUp:self.nameText.text withPassword:self.passwordText.text withMetadata:metaData];
    
    NSString *error = [user errorMessage];
    if ([error isEqualToString:@""]){
        
        ImageCache * cache = [ImageCache sharedObject];
        [cache setLoginUserName:self.nameText.text];
        UserDB *userDB = [[UserDB alloc] init];
        [userDB insertDB:0 name:self.nameText.text withPassword:self.passwordText.text];
        
        STreamCategoryObject *scov = [[STreamCategoryObject alloc] initWithCategory:@"Voted"];
        STreamObject *so = [[STreamObject alloc] init];
        [so setObjectId:self.nameText.text];
        NSMutableArray *allvoted = [[NSMutableArray alloc] init];
        [allvoted addObject:so];
        [scov updateStreamCategoryObjects:allvoted];
        STreamObject *follower = [[STreamObject alloc]init];
        STreamObject *following = [[STreamObject alloc]init];
        [follower setObjectId:[NSString stringWithFormat:@"%@Follower",self.nameText.text]];
        [following setObjectId:[NSString stringWithFormat:@"%@Following",self.nameText.text]];
        [follower createNewObject:^(BOOL succeed, NSString *response){
            if (!succeed)
                NSLog(@"res: %@", response);
        }];
        [following createNewObject:^(BOOL succeed, NSString *response){
            if (!succeed)
                NSLog(@"res: %@", response);
        }];

    }else{
     
        UIAlertView * view  = [[UIAlertView alloc]initWithTitle:@"" message:@"用户名重名了" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
    }
   

}

//UITextFied
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self.rePassword resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
-(void)performDismiss:(NSTimer *)timer{
    
    [alertview dismissWithClickedButtonIndex:0 animated:YES];

}

//----pick actionsheet
-(void)segmentAction:(UISegmentedControl*)seg{
    NSInteger index = seg.selectedSegmentIndex;
    NSLog(@"%d",index);
    [self.actionSheet dismissWithClickedButtonIndex:index animated:YES];
}


#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (isAddImage) {
        if (buttonIndex == 1)
        {
            [self addPhoto];
        }
        else if(buttonIndex == 2)
        {
            [self takePhoto];
        }

    }
        isAddImage = NO;

}

//image
-(void) imageClicked{
    isAddImage = YES;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"插入图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"系统相册",@"拍摄", nil];
    alert.delegate = self;
    [alert show];
    
}
#pragma mark - Tool Methods
- (void)addPhoto
{
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = NO;
	[self presentViewController:imagePickerController animated:YES completion:NULL];
    

}

- (void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该设备不支持拍照功能"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"好", nil];
        [alert show];
    }
    else
    {
        UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        [self presentViewController:imagePickerController animated:YES completion:NULL];
      
    }
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    picked = TRUE;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.imageview.image = image;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
