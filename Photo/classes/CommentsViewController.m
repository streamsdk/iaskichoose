//
//  CommentsViewController.m
//  Photo
//
//  Created by wangsh on 13-9-26.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "CommentsViewController.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamUser.h>
#import "ImageCache.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageDownload.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
@interface CommentsViewController ()
{
    NSString *leftImageId;
    NSString *rightImageId;
//    UITextField *contentsText;
    UITextView *contentsText;
    NSMutableArray *allKeys;
    NSMutableArray *userNameArray;
    NSMutableArray *contentsArray;
    UIToolbar *toolBar;
    UIActivityIndicatorView *imageViewActivity;
}
@end

@implementation CommentsViewController
@synthesize oneImageView;
@synthesize twoImageView;
@synthesize rowObject;
@synthesize headImageView;
@synthesize nameLable;
@synthesize contentView;
@synthesize messageLabel;

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
    self.title = @"评论";
    leftImageId = [rowObject getValue:@"file1"];
    rightImageId = [rowObject getValue:@"file2"];
    userNameArray = [[NSMutableArray alloc]init];
    contentsArray = [[NSMutableArray alloc]init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]< 7.0) {
        toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-80, self.view.frame.size.width, 40)];
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-86)];

    }else{
        toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 40)];
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
    }

    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.tag =TABLEVIEWTAG;
    myTableView.separatorStyle=YES;//UITableView每个cell之间的默认分割线隐藏掉sel
    [self.view addSubview:myTableView];
    
    toolBar.backgroundColor= [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    toolBar.tag = TOOLBARTAG;
    [self.view addSubview:toolBar];
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    
    contentsText = [[UITextView alloc]initWithFrame:CGRectMake(0, 5, 250, 30)];
    contentsText.delegate = self;
    contentsText.font = [UIFont systemFontOfSize:14.0f];
    contentsText.layer.borderColor = [UIColor grayColor].CGColor;
    contentsText.layer.borderWidth =1.0;
    contentsText.layer.cornerRadius =5.0;
    contentsText.text = @"请输入您的评论";
    contentsText.textColor = [UIColor lightGrayColor];
    UIBarButtonItem * contentsItem = [[UIBarButtonItem alloc] initWithCustomView:contentsText];
    
    UIButton * senderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    senderButton.frame = CGRectMake(250, 0, 50, 40);
    [senderButton setTitle:@"发送" forState:UIControlStateNormal];
    [senderButton addTarget:self action:@selector(senderClicker) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * senderItem = [[UIBarButtonItem alloc] initWithCustomView:senderButton];
    
    [array addObject:contentsItem];
    [array addObject:senderItem];
    toolBar.items = array;
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif


    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"读取中...";
    [self.view addSubview:HUD];
    //[HUD showWhileExecuting:@selector(loadComments) onTarget:self withObject:nil animated:YES];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadComments];
    }completionBlock:^{
        [myTableView reloadData];
         [HUD removeFromSuperview];
        HUD = nil;
    }];

    UIView *backgrdView = [[UIView alloc] initWithFrame:myTableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    myTableView.backgroundView = backgrdView;
}
- (void)loadComments{
    STreamObject *test = [[STreamObject alloc] init];
    [test setObjectId:[rowObject objectId]];
    [test loadAll:[rowObject objectId]];
    NSArray *temp = [NSMutableArray arrayWithArray:[test getAllKeys]];
    temp = [temp sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b){
        return [a compare:b];
    }];
    allKeys = [NSMutableArray arrayWithArray:temp];

    if ([allKeys count]!=0 ) {
        for (NSString *key in allKeys){
            
            NSMutableDictionary *comme = [test getValue:key];
            NSEnumerator *con = [comme keyEnumerator];
            NSString *dicKey = [con nextObject];
            if (dicKey){
                NSString *contents  = [comme objectForKey:dicKey];
                [contentsArray addObject:contents];
                [userNameArray addObject:dicKey];
            }
            NSLog(@"dicKey%@",dicKey);
        }
    }
}

//创建cell上控件
-(void)createUIControls:(UITableViewCell *)cell withCellRowAtIndextPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(60,0, 200, 40)];
        self.messageLabel.font =[UIFont systemFontOfSize:15.0f];
        self.messageLabel .backgroundColor = [UIColor clearColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        //自动折行设置
        self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.messageLabel.numberOfLines = 0;
        [cell.contentView addSubview:self.messageLabel];
        
        self.oneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 50, 150, 150)];
        [self.oneImageView setImage:[UIImage imageNamed:@"headImage.jpg"] ];
        [cell addSubview:self.oneImageView];
        
        self.twoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(165, 50, 150, 150)];
        [self.twoImageView setImage:[UIImage imageNamed:@"headImage.jpg"] ];
        [cell addSubview:self.twoImageView];
        
    }else{
        imageViewActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [imageViewActivity setCenter:CGPointMake(22,25)];
        [imageViewActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [cell.contentView addSubview:imageViewActivity];
        [imageViewActivity startAnimating];
        
        [self getCellHeight:indexPath.row];
        headImageView =  [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 40, 40)];
        [headImageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        [cell addSubview:headImageView];
        
        nameLable = [[UILabel alloc]initWithFrame:CGRectMake(56, 0, 150, 30)];
        nameLable.textColor = [UIColor blueColor];
        nameLable.font = [UIFont systemFontOfSize:15];
        nameLable.backgroundColor = [UIColor clearColor];
        [cell addSubview:nameLable];
        
        contentView =[[UITextView alloc]initWithFrame:CGRectMake(50, 30, 260, [self getCellHeight:indexPath.row])];
        contentView.delegate = self;
        [contentView setEditable:NO];
        contentView.textAlignment = NSTextAlignmentLeft;
        contentView.font = [UIFont systemFontOfSize:13];
        contentView.backgroundColor = [UIColor clearColor];
        [cell addSubview:contentView];
       
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [allKeys count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath ];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        
        [self createUIControls:cell withCellRowAtIndextPath:indexPath];
    }
    ImageCache *cache = [ImageCache sharedObject];
    NSString *file1 = [rowObject getValue:@"file1"];
    NSString *file2 = [rowObject getValue:@"file2"];
    self.messageLabel.text = [rowObject getValue:@"message"];
    
    self.oneImageView.image = [UIImage imageWithData:[cache getImage:file1]];
    self.twoImageView.image = [UIImage imageWithData:[cache getImage:file2]];
    if (indexPath.row !=0) {
        nameLable.text = [userNameArray objectAtIndex:indexPath.row-1];
        contentView.text = [contentsArray objectAtIndex:indexPath.row-1];
        
        NSString *currentRowUserName = [userNameArray objectAtIndex:indexPath.row-1];
        NSMutableDictionary *userMetaData = [cache getUserMetadata:currentRowUserName];
        //download usermeta data and user image
        if (userMetaData){
            NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
            if (pImageId && ![cache getImage:pImageId]){
                ImageDownload *imageDownload = [[ImageDownload alloc] init];
                [imageDownload downloadFile:pImageId];
                [headImageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
            }else{
              if (pImageId)
                  [headImageView setImage:[UIImage imageWithData:[cache getImage:pImageId]]];
            }
        
        }else{
            STreamUser *user = [[STreamUser alloc] init];
            [user loadUserMetadata:currentRowUserName response:^(BOOL succeed, NSString *error){
                if ([error isEqualToString:currentRowUserName]){
                    NSMutableDictionary *dic = [user userMetadata];
                    [cache saveUserMetadata:currentRowUserName withMetadata:dic];
                }
            }];
            [headImageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        }

    }
    return cell;
}
-(CGFloat)getCellHeight:(NSInteger)row
{
    // 列寬
    CGFloat contentWidth =self.view.frame.size.width-85;
    CGFloat height = 0.0;
    // 设置字体
    UIFont *font = [UIFont systemFontOfSize:15];
    
    if (contentsArray.count != 0) {
      
        // 显示的内容
        NSString *content = [contentsArray objectAtIndex:row-1];
        
        // 计算出显示完內容需要的最小尺寸
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 3000)];
        
        
        if (size.height<=30) {
            height = 60;
        }else
        {
            height = size.height+60;//40
        }
    }
    
    // 返回需要的高度
    return height;
    
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 220;
    }else{
        return  [self getCellHeight:indexPath.row];
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    contentsText.text=@"";
    contentsText.textColor = [UIColor blackColor];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)addComments{
    
    ImageCache *cache = [ImageCache sharedObject];
    NSDate *now = [[NSDate alloc] init];
    long millionsSecs = [now timeIntervalSince1970];
    NSString *longValue = [NSString stringWithFormat:@"%lu", millionsSecs];
    STreamObject *comment = [[STreamObject alloc] init];
    [comment setObjectId:[rowObject objectId]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:contentsText.text forKey:[cache getLoginUserName]];
    [comment addStaff:longValue withObject:dic];
    [comment update];
    int length =  [contentsArray count];
    [contentsArray insertObject:contentsText.text atIndex:length];
    [userNameArray insertObject:[cache getLoginUserName] atIndex:length];
    [allKeys insertObject:[rowObject objectId] atIndex:length];
    
}

-(void)senderClicker{
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"添加评论...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self addComments];
    } completionBlock:^{
        contentsText.text = @"";
        [contentsText resignFirstResponder];
        [myTableView reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    
}
//UITextFied
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void) autoMovekeyBoard: (float) h{
    
    
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]< 7.0) {
        toolbar.frame = CGRectMake(0.0f, (float)(480.0-h-105.0), 320.0f, 40.0f);
    }else{
        toolbar.frame = CGRectMake(0.0f, (float)(480.0-h-40.0), 320.0f, 40.0f);
    }
//	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
//	tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f,(float)(480.0-h-40.0));
}

#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
   
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self autoMovekeyBoard:keyboardRect.size.height];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    [self autoMovekeyBoard:0];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
