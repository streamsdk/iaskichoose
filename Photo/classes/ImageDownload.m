//
//  ImageDownload.m
//  Photo
//
//  Created by wang shuai on 16/09/2013.
//  Copyright (c) 2013 wangshuai. All rights reserved.
//

#import "ImageDownload.h"
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamQuery.h>
#import "ImageCache.h"
#import "FileCache.h"

@implementation ImageDownload

@synthesize mainRefesh;
@synthesize data1;
@synthesize data2;

- (void)downloadFile:(NSString *)fileId{
    
    
    ImageCache *imageCache = [ImageCache sharedObject];
    FileCache *fileCache = [FileCache sharedObject];
    STreamFile *file = [[STreamFile alloc] init];
    if (![imageCache getImage:fileId]){
        [file downloadAsData:fileId downloadedData:^(NSData *imageData, NSString *oId) {
             if ([fileId isEqualToString:oId]){
                 [imageCache selfImageDownload:imageData withFileId:fileId];
                 [fileCache writeFile:fileId withData:imageData];
                 if (mainRefesh)
                     [mainRefesh reloadTable];
             }
         }];
    }
}

@end
