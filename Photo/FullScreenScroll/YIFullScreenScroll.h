//
//  YIFullScreenScroll.h
//  Photo
//
//  Created by wangsh on 13-9-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YIFullScreenScroll : NSObject<UIScrollViewDelegate>
{
    CGFloat _prevContentOffsetY;
    
    BOOL    _isScrollingTop;
}

@property (strong, nonatomic) UIViewController* viewController;

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL shouldShowUIBarsOnScrollUp;

- (id)initWithViewController:(UIViewController*)viewController;

- (void)layoutTabBarController; // set on viewDidAppear, if using tabBarController

- (void)showUIBarsWithScrollView:(UIScrollView*)scrollView animated:(BOOL)animated;


@end
