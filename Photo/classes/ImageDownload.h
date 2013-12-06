//
//  ImageDownload.h
//  Photo
//
//  Created by wang shuai on 16/09/2013.
//  Copyright (c) 2013 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewTableViewRfresh.h"

@interface ImageDownload : NSObject

@property (nonatomic, weak) id<MainViewTableViewRfresh> mainRefesh;

@property (nonatomic, weak) NSData *data1;
@property (nonatomic, weak) NSData *data2;

- (void)downloadFile:(NSString *)fileId;

@end
