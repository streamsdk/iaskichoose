//
//  SingleImageViewController.h
//  Photo
//
//  Created by wangshuai on 13-10-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <arcstreamsdk/STreamObject.h>

@interface SingleImageViewController : MainViewController

@property (retain,nonatomic) STreamObject * so;
@end
