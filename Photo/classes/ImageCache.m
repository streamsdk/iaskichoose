//
//  ImageDownload.m
//  Photo
//
//  Created by wangshuai on 13-9-16.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "ImageCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "VoteResults.h"
#import "FileCache.h"

static NSMutableDictionary *_imageDictionary;
static NSMutableDictionary *_selfImageDictionary;
static NSMutableDictionary *_userMetaData;
static NSMutableDictionary *_voteResults;
static NSMutableString *loginUserName;
static NSString *password;
static FileCache *fileCache;
static NSMutableArray *_cachedSelfImageFiles;

@implementation ImageCache


+ (ImageCache *)sharedObject{
    
    static ImageCache *sharedInstance;
    static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
        
         sharedInstance = [[ImageCache alloc] init];
         fileCache = [FileCache sharedObject];
         _cachedSelfImageFiles = [[NSMutableArray alloc] init];
         _imageDictionary = [[NSMutableDictionary alloc] init];
         _selfImageDictionary = [[NSMutableDictionary alloc] init];
         _userMetaData = [[NSMutableDictionary alloc] init];
         _voteResults = [[NSMutableDictionary alloc] init];
         
     });
    
    return sharedInstance;
    
}

-(void)setLoginPassword:(NSString *)p{
    password = p;
}

-(NSString *)getLoginPassword{
    return password;
}

-(void)setLoginUserName:(NSString *)userName{
    loginUserName = [[NSMutableString alloc] init];
    [loginUserName appendString:userName];
}

-(void)resetUserNamePassword{
    loginUserName = nil;
    password = nil;
}

-(NSMutableString *)getLoginUserName{
    return loginUserName;
}

-(NSMutableDictionary *)getUserMetadata:(NSString *)userName{
    return [_userMetaData objectForKey:userName];
}

-(void)saveUserMetadata:(NSString *)userName withMetadata:(NSMutableDictionary *)metaData{
    [_userMetaData setObject:metaData forKey:userName];
}

-(void)selfImageDownload:(NSData *)file withFileId:(NSString *)fileId{
    if ([_cachedSelfImageFiles count] >= 40){
        
        for (int i=0; i < 1; i++){
            NSString *fId = [_cachedSelfImageFiles objectAtIndex:i];
            [_selfImageDictionary removeObjectForKey:fId];
            [_cachedSelfImageFiles removeObjectAtIndex:i];
        }
        
    }
    [_cachedSelfImageFiles addObject:fileId];
    [_selfImageDictionary setObject:file forKey:fileId];
}

-(NSData *)getImage:(NSString *)fileId{
    NSData *data =  [_selfImageDictionary objectForKey:fileId];
    if (data){
  
    }else{
        data = [fileCache readFromFile:fileId];
        if (data)
            [_selfImageDictionary setObject:data forKey:fileId];
    }
    
    return data;
}

-(void)addVotesResults:(NSString *)objectId withVoteResult:(VoteResults *)results{
    [_voteResults setObject:results forKey:objectId];
}

-(VoteResults *)getResults:(NSString *)objectId{
    return [_voteResults objectForKey:objectId];
}

@end
