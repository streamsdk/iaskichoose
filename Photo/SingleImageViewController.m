//
//  SingleImageViewController.m
//  Photo
//
//  Created by wangshuai on 13-10-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SingleImageViewController.h"
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamUser.h>

#import "VoteResults.h"
#import "ImageCache.h"
#import "ImageDownload.h"

@interface SingleImageViewController ()

@end

@implementation SingleImageViewController

@synthesize so;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.votesArray = [[NSMutableArray alloc] init];
    [self.votesArray addObject:so];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [votesArray count];
}

- (void) initBarRefresh{
    
}

- (void)loadVotes{
    
    ImageCache *imageCache = [ImageCache sharedObject];
    STreamQuery *st = [[STreamQuery alloc] initWithCategory:@"Voted"];
    [st whereKeyExists:[so objectId]];
    
    NSMutableArray *sos = [st find];
    int f1 = 0;
    int f2 = 0;
    
    VoteResults *vo = [[VoteResults alloc] init];
    for (STreamObject *so1 in sos){
        NSString *voted = [so1 getValue:[so objectId]];
        if (voted != nil && [voted isEqualToString:@"f1voted"])
            f1++;
        if (voted != nil && [voted isEqualToString:@"f2voted"])
            f2++;
    }
    
    int total = f1 + f2;
    int vote1count;
    int vote2count;
    if (total) {
        vote1count = ((float)f1/total)*100;
        vote2count = ((float)f2/total)*100;
        NSString *vote1 = [NSString stringWithFormat:@"%d%%",vote1count];
        NSString *vote2 = [NSString stringWithFormat:@"%d%%",vote2count];
        
        [vo setObjectId:[so objectId]];
        [vo setF1:vote1];
        [vo setF2:vote2];
        
        [imageCache addVotesResults:[so objectId] withVoteResult:vo];
        
    }else{
        vote1count=0;
        vote2count=0;
    }

    
}

@end
