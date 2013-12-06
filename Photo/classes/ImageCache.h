//
//  ImageDownload.h
//  Photo
//
//  Created by wangshuai on 13-9-16.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoteResults.h"

@interface ImageCache : NSObject
{
    
}

+ (ImageCache *)sharedObject;

-(void)resetUserNamePassword;

-(void)selfImageDownload:(NSData *)file withFileId:(NSString *)fileId;

-(NSData *)getImage:(NSString *)fileId;

-(void)saveUserMetadata:(NSString *)userName withMetadata:(NSMutableDictionary *)metaData;

-(NSMutableDictionary *)getUserMetadata:(NSString *)userName;

-(void)setLoginUserName:(NSString *)userName;

-(NSMutableString *)getLoginUserName;

-(void)addVotesResults:(NSString *)objectId withVoteResult:(VoteResults *)results;

-(VoteResults *)getResults:(NSString *)objectId;

-(void)setLoginPassword:(NSString *)p;

-(NSString *)getLoginPassword;

@end
