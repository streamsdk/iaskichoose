//
//  AppDelegate.h
//  Photo
//
//  Created by wangshuai on 13-9-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL loginSuccess;
    UIImageView * imageview ;
}
@property (assign, nonatomic) BOOL loginSuccess;

@property (strong, nonatomic) UIWindow *window;

-(void)showLoginSucceedView;
-(void)showLoginView;
-(void)showMainView;
@end
