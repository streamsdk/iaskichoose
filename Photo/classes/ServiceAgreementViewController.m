//
//  ServiceAgreementViewController.m
//  我问我选
//
//  Created by wangsh on 13-10-30.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "ServiceAgreementViewController.h"

@interface ServiceAgreementViewController ()

@end

@implementation ServiceAgreementViewController

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
    UIWebView * webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    [self.view addSubview: webView];
    NSString *urlString = @"http://streamsdk.cn/ask/eula.html";
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
