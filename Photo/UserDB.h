//
//  UserDB.h
//  Photo
//
//  Created by wangsh on 13-10-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDB : NSObject

-(void)initiDB;


-(void)insertDB:(int)rowNum name:(NSString *)userName withPassword:(NSString *)password;


-(void)logout;

@end
