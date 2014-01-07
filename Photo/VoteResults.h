//
//  VoteResults.h
//  Photo
//
//  Created by wangsh on 13-9-24.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoteResults : NSObject{
    
    
}

@property (retain,nonatomic)NSString *objectId;
@property (retain,nonatomic)NSString *f1;
@property (retain,nonatomic)NSString *f2;
@property (retain,nonatomic)NSString *userName;
@property(assign,nonatomic) int f1count;
@property(assign,nonatomic) int f2count;

@end
