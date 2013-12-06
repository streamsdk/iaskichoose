//
//  QuestionViewController.m
//  Photo
//
//  Created by wangsh on 13-10-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "QuestionViewController.h"
#import "PhotoViewController.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController
@synthesize mTableView;
@synthesize dataArray;
@synthesize messagePro;

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
	// Do any additional setup after loading the view.
    
    mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height) style:UITableViewStylePlain];
    mTableView.dataSource = self;
    mTableView .delegate = self;
    mTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:mTableView];
    UIView *backgrdView = [[UIView alloc] initWithFrame:mTableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    mTableView.backgroundView = backgrdView;
    dataArray = [[NSArray alloc]initWithObjects:@"哪个好？",@"哪个看起来好？",@"穿哪一个？",@"哪个更适合我？",@"你选择哪个？",@"买哪个？",@"你帮我选择？", nil];

}

#pragma mark-------------tableView-------------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellName =@"CellID";
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
    }
    cell.textLabel.text = [dataArray objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
      //PhotoViewController *photoView = [[PhotoViewController alloc]init];
    //photoView.messages= [dataArray objectAtIndex:indexPath.row];
    [messagePro selectMessage:[dataArray objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
