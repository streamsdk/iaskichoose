//
//  FileCache.m
//  Photo
//
//  Created by wangsh on 13-10-7.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "FileCache.h"

@implementation FileCache

static NSMutableArray *cachedFiles;

+ (FileCache *)sharedObject{
    
    static FileCache *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[FileCache alloc] init];
        
    });
    
    return sharedInstance;

}


- (void)writeFile:(NSString *)fileName withData:(NSData *)data{
    
    NSString *fName = [[self tempPath] stringByAppendingPathComponent:fileName];
    [data writeToFile:fName atomically:YES];
    
}

-(NSData *)readFromFile:(NSString *)fileName{
    
    NSString *fName = [[self tempPath] stringByAppendingPathComponent:fileName];
  ///  NSData *content = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fName]];
  //  return content;
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fName];
    NSData *content = [fileHandle readDataToEndOfFile];
    return content;
    
}

-(NSString *) documentsPath {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}


-(NSString *) tempPath{
    return NSTemporaryDirectory();
}

@end
