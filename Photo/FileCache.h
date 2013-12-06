//
//  FileCache.h
//  Photo
//
//  Created by wangsh on 13-10-7.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject{
    
}

+ (FileCache *)sharedObject;

- (void)writeFile:(NSString *)fileName withData:(NSData *)data;

- (NSData *)readFromFile:(NSString *)fileName;


@end
