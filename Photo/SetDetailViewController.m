//
//  SetDetailViewController.m
//  Photo
//
//  Created by wangsh on 13-10-10.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SetDetailViewController.h"
#import "ImageCache.h"
#import <QuartzCore/QuartzCore.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamFile.h>
#import "UserDB.h"
#import "MBProgressHUD.h"
#import "InformationViewController.h"
@interface SetDetailViewController ()

{
    BOOL isAddImage;
    NSData * imageData;
    STreamUser * user;
    ImageCache * cache;
    NSMutableDictionary * dict;
    STreamFile *file;
}
@end

@implementation SetDetailViewController

@synthesize string;
@synthesize nameLabel;
@synthesize nameTextFied;
@synthesize passwordTextFied;
@synthesize passworLabel;
@synthesize headImage;
@synthesize doneButton;
@synthesize repasswordTextFied;
@synthesize repassworLabel;
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
    self.view.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    
    cache = [ImageCache sharedObject];
    user = [[STreamUser alloc]init];
    dict = [[NSMutableDictionary alloc]init];
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[doneButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[doneButton  layer] setBorderWidth:1];
    [[doneButton layer] setCornerRadius:5];
    [doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(selectAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    if ([string isEqualToString:@"修改昵称"]) {
        self.title = @"修改昵称";
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 60, 40)];
        nameLabel.text = @"昵称";
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:nameLabel];
        nameTextFied = [[UITextField alloc]initWithFrame:CGRectMake(80, 80, 200, 40)];
        nameTextFied.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:nameTextFied];
        doneButton.tag = 1;
        [doneButton setFrame:CGRectMake(100, 160, 120, 40)];
    }
    if ([string isEqualToString:@"修改密码"]) {
        self.title = @"修改密码";
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 60, 40)];
        nameLabel.text = @"原密码";
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:nameLabel];
        nameTextFied = [[UITextField alloc]initWithFrame:CGRectMake(80, 80, 200, 40)];
        nameTextFied.delegate = self;
        [nameTextFied setSecureTextEntry:YES];
        nameTextFied.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:nameTextFied];
        passworLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 130, 60, 40)];
        passworLabel.text = @"新密码";
        passworLabel.backgroundColor = [UIColor clearColor];
        passworLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:passworLabel];
        passwordTextFied = [[UITextField alloc]initWithFrame:CGRectMake(80, 130, 200, 40)];
        passwordTextFied.borderStyle = UITextBorderStyleRoundedRect;
        [passwordTextFied setSecureTextEntry:YES];
        passwordTextFied.delegate = self;
        [self.view addSubview:passwordTextFied];
        repassworLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 180, 75, 40)];
        repassworLabel.text = @"确认密码";
        repassworLabel.backgroundColor = [UIColor clearColor];
        repassworLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:repassworLabel];
        repasswordTextFied = [[UITextField alloc]initWithFrame:CGRectMake(80, 180, 200, 40)];
        repasswordTextFied.borderStyle = UITextBorderStyleRoundedRect;
        [repasswordTextFied setSecureTextEntry:YES];
        repasswordTextFied.delegate = self;
        [self.view addSubview:repasswordTextFied];
        doneButton.tag = 2;
        [doneButton setFrame:CGRectMake(100, 240, 120, 40)];
        
    }
    if ([string isEqualToString:@"修改头像"]) {
        self.title = @"修改头像";
        
        headImage = [[UIImageView alloc]initWithFrame:CGRectMake(85, 100, 150, 150)];
        headImage.image = [UIImage imageNamed:@"profile1.png"];
        headImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)];
        [ self.headImage  addGestureRecognizer:singleTap];
        [self.view addSubview:headImage];
        
        doneButton.tag = 3;
        [doneButton setFrame:CGRectMake(100, 300, 120, 40)];
    }
}
#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([nameTextFied.text isEqualToString:[cache getLoginPassword]]) {
        
    }else{
        nameTextFied.text = @"";
        UIAlertView * alertView  =[[UIAlertView alloc]initWithTitle:@"" message:@"你输入的密码错误" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil, nil];
        [alertView show];
    }
}
-(void)selectAction
{
    UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"你确定要更改信息吗" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.delegate = self;
    if (doneButton.tag == 1) {
        [dict setValue:self.nameTextFied.text forKey:@"nickname"];
        [alertView show];
    }
    if (doneButton.tag == 2) {
        if (([passwordTextFied.text length]!=0)&&([nameTextFied.text length]!=0)&&([repasswordTextFied.text length]!=0) ) {
            NSLog(@"%@  %@",passwordTextFied.text,repasswordTextFied.text);
            
            if ([passwordTextFied.text isEqualToString:repasswordTextFied.text])
            {
                [dict setValue:self.passwordTextFied.text forKey:@"password"];
                UserDB *db = [[UserDB alloc]init];
                [db insertDB:0 name:[cache getLoginUserName] withPassword:passwordTextFied.text];
                [alertView show];
                
            }else{
                UIAlertView *alertView2  = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.delegate = self;
                [alertView2 show];
            }
            
        }else{
            UIAlertView *alertView2  = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alertView.delegate = self;
            [alertView2 show];
        }
    }
    
    if (doneButton.tag == 3) {
        if ([imageData length]) {
            file = [[STreamFile alloc]init];
            __block NSString *res;
            [file postData:imageData finished:^(NSString *response){
                NSLog(@"res: %@", response);
                res = response;
            }byteSent:^(float percentage){
                NSLog(@"total: %f", percentage);
            }];
            [alertView show];
        }else{
            UIAlertView *alertView2  = [[UIAlertView alloc]initWithTitle:@"" message:@"请上传头像" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView2 show];
        }
    }
}
- (void)upload{
    sleep(5);
    NSString *fileId = [file fileId];
    int loopCount = 0;
    while(fileId == nil ){
        sleep(2);
        loopCount++;
        if (loopCount > 20)
            break;
        fileId = [file fileId];
    }
    
    if (fileId == nil)
        return;
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
        
    }else{
        if (buttonIndex == 1) {
            InformationViewController *inforView  = [[InformationViewController alloc]init];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"提交中...";
            [self.view addSubview:HUD];
            if (doneButton.tag == 3) {
                [HUD showAnimated:YES whileExecutingBlock:^{
                    [self upload];
                } completionBlock:^{
                    if ([file fileId]){
                        [dict setValue:[file fileId] forKey:@"profileImageId"];
                        [user updateUserMetadata:[cache getLoginUserName] withMetadata:dict];
                        [self.navigationController pushViewController:inforView animated:YES];
                        NSLog(@"dict= %@",dict);
                    }
                }];
            }else{
                [HUD showAnimated:YES whileExecutingBlock:^{
                } completionBlock:^{
                    [user updateUserMetadata:[cache getLoginUserName] withMetadata:dict];
                     [self.navigationController pushViewController:inforView animated:YES];
                }];
            }
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

- (void)takePhoto{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该设备不支持拍照功能"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"好", nil];
        [alert show];
    }else{
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
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.headImage.image = image;
    UIImage *sImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(300.0, 300.0)];
    imageData = UIImageJPEGRepresentation(sImage, 0.1);
}
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
