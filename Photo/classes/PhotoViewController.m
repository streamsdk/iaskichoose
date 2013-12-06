//
//  PhotoViewController.m
//  Photo
//
//  Created by wangshuai on 13-9-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "PhotoViewController.h"
#import "LoginViewController.h"
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamObject.h>
#import "MBProgressHUD.h"
#import "ImageCache.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "QuestionViewController.h"

static BOOL isExistingLeftImage;
static BOOL isExistingRightImage;
static UIImage * leftImage;
static UIImage * rightImage;

@interface PhotoViewController ()
{
    BOOL isUpload;
    BOOL isAddImage;
    int clicked1;
    NSData *imageData1;
    NSData *imageData2;
    STreamFile *file1;
    STreamFile *file2;
    UIToolbar* keyboardDoneButtonView;

}

@end

@implementation PhotoViewController
@synthesize imageView = _imageView;
@synthesize imageView2 = _imageView2;
@synthesize imagePicker = _imagePicker;
@synthesize message = _message;
@synthesize myTableView = _myTableView;
@synthesize registerButton;
@synthesize messages;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)pickerDoneClicked
{
    UITextView* view = (UITextView*)[self.view viewWithTag:1001];
    [view resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    clicked1 = 0;
    self.navigationItem.hidesBackButton = YES;
    self.title = @"拍 照";
    keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
//    UIBarButtonItem *SpaceButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                               target:nil  action:nil];
//    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成"
//                                                                   style:UIBarButtonItemStyleDone target:self
//                                                                  action:@selector(pickerDoneClicked)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    self.navigationController.navigationItem.backBarButtonItem = NO;
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height) style:UITableViewStylePlain];
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    self.myTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.myTableView];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.separatorStyle=NO;//UITableView每个cell之间的默认分割线隐藏掉
    //background
    UIView *backgrdView = [[UIView alloc] initWithFrame:_myTableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    _myTableView.backgroundView = backgrdView;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellName =@"CellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 150, 150)];
        self.imageView .userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked:)];
        [ self.imageView  addGestureRecognizer:singleTap];
        [cell addSubview: self.imageView ];
        
        self.imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(165, 10, 150, 150)];
        self.imageView2 .userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked2:)];
        [ self.imageView2  addGestureRecognizer:singleTap2];
        [cell addSubview: self.imageView2 ];
        if (isExistingLeftImage) {
            self.imageView.image = leftImage;
        }else{
            [self.imageView setImage:[UIImage imageNamed:@"upload2.png"]];
        }
        if (isExistingRightImage) {
            self.imageView2.image = rightImage;
        }else{
            [self.imageView2 setImage:[UIImage imageNamed:@"upload2.png"]];
        }

        UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(5, 180, 310,120)];
        [button setImage:[UIImage imageNamed:@"question2.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(questionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];

        
        _message = [[UITextView alloc]initWithFrame:CGRectMake(5, 0, 280, 120)];
        _message.font = [UIFont systemFontOfSize:20];
        _message.backgroundColor =[UIColor clearColor];
        _message.delegate = self;
        _message.tag =1001;
        _message.inputAccessoryView =keyboardDoneButtonView;
        [button addSubview:_message];
        if (messages==nil) {
            
            _message.textColor = [UIColor lightGrayColor];
            _message.text = @"描述(限40个字)";
        }else{
            _message.text = messages;
        }
        
        registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[registerButton  layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[registerButton  layer] setBorderWidth:1];
        [[registerButton layer] setCornerRadius:5];
        [registerButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        registerButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [registerButton setFrame:CGRectMake(55, 320, 210, 40)];
//        [registerButton setImage:[UIImage imageNamed:@"submit.png"] forState:UIControlStateNormal];
        [registerButton setTitle:@"提交" forState:UIControlStateNormal];
        [registerButton addTarget:self action:@selector(selectRightAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:registerButton];

    }
    return cell;
}

- (void)selectMessage:(NSString *)message{
    messages = message;
    _message.text = messages;
}

-(void)questionButtonClicked
{
    QuestionViewController *questionView = [[QuestionViewController alloc]init];
    [questionView setMessagePro:self];
    
    [self.navigationController pushViewController:questionView animated:YES];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 400;//
}

#pragma mark - textViewDelegate
//UITextView
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if (textView.text.length>40)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您输入超过40个字了" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        alert.delegate = self;
        [alert show];
        return NO;
    }
    else
    {
        return YES;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }

}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([_message.text isEqualToString:@"描述(限40个字)"])
         _message.text=@"";
    _message.textColor = [UIColor blackColor];
    CGRect frame= CGRectMake(0, -130, 320, 400);
    self.myTableView.frame = frame;
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect frame;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]< 7.0) {
        frame =CGRectMake(0,0, 320,400);

    }else{
        frame =CGRectMake(0,0, 320, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height);

    }
    self.myTableView.frame = frame;
}
-(void) selectRightAction:(UIButton *)button{
    isUpload = YES;
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您确定要上传吗?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.delegate = self;
    [alertView show];
}

- (void)upload{
    
    file1 = [[STreamFile alloc] init];
    file2 = [[STreamFile alloc] init];
    [file1 postData:imageData1];
    [file2 postData:imageData2];
    sleep(2);
    NSString *file1Id = [file1 fileId];
    NSString *file2Id = [file2 fileId];
   
    if (file1Id && file2Id && [[file1 errorMessage] isEqualToString:@""] && [[file2 errorMessage] isEqualToString:@""]){
        
        NSDate *now = [[NSDate alloc] init];
        long millionsSecs = [now timeIntervalSince1970];
        int i = arc4random();
        long unique = millionsSecs + i;
        
        NSString *longValue = [NSString stringWithFormat:@"%lu", unique];
        
        ImageCache *cache = [[ImageCache alloc] init];
        NSString *userName = [cache getLoginUserName];
        
        STreamObject *vote = [[STreamObject alloc] init];
        [vote setObjectId:longValue];
        [vote addStaff:@"file1" withObject:file1Id];
        [vote addStaff:@"file2" withObject:file2Id];
        [vote addStaff:@"message" withObject:_message.text];
        [vote addStaff:@"userName" withObject:userName];
        [vote addStaff:@"flag" withObject:@"false"];
        [vote addStaff:@"creationTime" withObject:[NSString stringWithFormat:@"%lu", millionsSecs]];
        
        STreamCategoryObject *scov = [[STreamCategoryObject alloc] initWithCategory:@"AllVotes"];
        NSMutableArray *av = [[NSMutableArray alloc] init];
        [av addObject:vote];
        [scov updateStreamCategoryObjects:av];
        
        STreamObject *comments = [[STreamObject alloc] init];
        [comments setObjectId:longValue];
        [comments createNewObject:^(BOOL succeed, NSString *response){
            
        }];        
    }
    
}

-(void) imageClicked:(UIImageView *)View{

    clicked1 = 1;
    isAddImage = YES;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"插入图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"系统相册",@"拍摄", nil];
    alert.delegate = self;
    [alert show];

}

-(void) imageClicked2:(UIImageView *)View{
    
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

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (clicked1 == 1){
       self.imageView.image = image;
        leftImage =image;
        isExistingLeftImage = YES;
       UIImage *sImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(380, 380)];
      // imageData1 = UIImageJPEGRepresentation(image, 1);
       imageData1 = UIImageJPEGRepresentation(sImage, 0.3);
     }else{
        self.imageView2.image = image;
        rightImage = image;
        isExistingRightImage = YES;
        UIImage *sImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(380, 380)];
        //  imageData2 = UIImageJPEGRepresentation(image, 1);
        imageData2 = UIImageJPEGRepresentation(sImage, 0.3);
    }
    clicked1 = 0;
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
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
    if (isUpload) {
        if (buttonIndex == 1) {
            if (([imageData1 length] == 0)|| ([imageData2 length]== 0)) {
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"你还没有上传图片？" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
                [alertView show];
            }else{
               MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
               [self.view addSubview:HUD];
               HUD.labelText = @"提交中...";
               [HUD showAnimated:YES whileExecutingBlock:^{
                   [self upload];
               } completionBlock:^{
                   NSString *file1Id = [file1 fileId];
                   NSString *file2Id = [file2 fileId];
                   if (file1Id && file2Id && [[file1 errorMessage] isEqualToString:@""] && [[file2 errorMessage] isEqualToString:@""]){
                       [APPDELEGATE showLoginSucceedView];
                       
                   }else{
                       UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"网络连接错误，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                       [alertView show];
                   }
                   isExistingLeftImage = NO;
                   isExistingRightImage = NO;
                }];
            }
        }
    }
    isAddImage = NO;
    isUpload = NO;
    [_message resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
