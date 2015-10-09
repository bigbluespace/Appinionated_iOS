//
//  Colleagues.m
//  Appinionated
//
//  Created by Tamal on 10/30/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "AppAPI.h"
#import "Colleagues.h"

@interface Colleagues (){
    NSDictionary *auth;
    NSMutableArray *groupData;
}
@property (weak, nonatomic) IBOutlet UITableView *groupQuesTable;

@end

@implementation Colleagues

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.title = [_group_data valueForKey:@"name"];
    //NSLog(@"%@", self.title);
    //NSLog(@"%@",_group_data);
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    groupData = [[NSMutableArray alloc] init];
    [self loadGroupData];
}

-(void)loadGroupData{//showGroupInfo
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI showGroupInfo:[[auth valueForKey:@"id"] integerValue] groupID:[[_group_data valueForKey:@"id"] integerValue] block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            groupData = [JSON valueForKey:@"question"];
            [_groupQuesTable reloadData];
        }else{
            UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No question found for this group" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMsgAlert show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groupData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger response;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colleaguesCell" forIndexPath:indexPath];
    ((UIImageView*)[cell viewWithTag:1]).image = nil;
    ((UILabel*)[cell viewWithTag:2]).text = nil;
    ((UILabel*)[cell viewWithTag:3]).text = nil;
    if ([groupData[indexPath.row] valueForKeyPath:@"Question.image"]!=nil) {
        [((UIImageView*)[cell viewWithTag:1]) setImageWithURL:[NSURL URLWithString:[groupData[indexPath.row] valueForKeyPath:@"Question.image"]]];
    }
    if ([groupData[indexPath.row] valueForKeyPath:@"Question.image"]!=nil) {
        ((UILabel*)[cell viewWithTag:2]).text = [groupData[indexPath.row]valueForKeyPath:@"Question.question"];
    }
    if ([groupData[indexPath.row] valueForKeyPath:@"Question.no_of_votes"]!=[NSNull null]) {
        response = [[groupData[indexPath.row] valueForKeyPath:@"Question.no_of_votes"] integerValue];
    }else{
        response = 0;
    }
    if ([groupData[indexPath.row]valueForKeyPath:@"Question.created"]!=nil){
        NSString *r = [NSString stringWithFormat:@"%@ - %lu response",[self setUpdateDate:[groupData[indexPath.row] valueForKeyPath:@"Question.created"]],(unsigned long)response];
        ((UILabel*)[cell viewWithTag:3]).text = r;
    }
    return cell;
}
-(NSString*)setUpdateDate:(NSString*) date{
    // Convert string to date object
    NSString *submitted_date;
   // NSLog(@" date %@",date);
    //NSDate *dateFormat = (NSDate*)date;
    // NSLog(@" dateFormat %@",dateFormat);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFormat = [dateFormatter dateFromString:date];
    
    //get time 11.05 AM
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *time = [timeFormatter stringFromDate:dateFormat];
  //  NSLog(@"formatere time %@",time);
    
    
    [timeFormatter setDateFormat:@"MMM"];
    NSString *monthName = [timeFormatter stringFromDate:dateFormat];
    //NSLog(@"get month %@",monthName);
    
    
    [timeFormatter setDateFormat:@"YYYY"];
    NSString *Year = [timeFormatter stringFromDate:dateFormat];
    
    [timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [timeFormatter setDateFormat:@"d"];
    NSString *date_day = [timeFormatter stringFromDate:dateFormat];
    
    submitted_date  = [NSString stringWithFormat:@"Submitted %@  %@ %@ %@",time,date_day,monthName,Year];
    
    return submitted_date;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
