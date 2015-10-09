//
//  MyQuestion.m
//  Appinionated
//
//  Created by Tamal on 10/30/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "MyQuestion.h"
#import "AppAPI.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "Question.h"
#import "SwipeCell.h"
#import "SelectContact.h"
#import "AskNewQuestion.h"

@interface MyQuestion (){
    NSDictionary *auth;
    NSMutableArray *questions;
    NSString *selectedQuestionId;
    NSString *name;
    NSIndexPath *indexPathDelete;
    NSUInteger offset;
    NSDateFormatter *df;
    NSUInteger limit;
    BOOL loadMore;
}
@property (weak, nonatomic) IBOutlet UITableView *myquestionTable;
@end

@implementation MyQuestion

- (void)viewDidLoad {
    [super viewDidLoad];
    df = [[NSDateFormatter alloc] init];
    offset = 0;
    limit = 10;
    loadMore = NO;
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    offset = 0;
    limit = 10;
    loadMore = NO;
    questions = [NSMutableArray array];
    [self loadAllQuestion];
    [_myquestionTable reloadData];
}

-(void)loadAllQuestion {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI recentQ:[[auth valueForKey:@"id"] integerValue]
              limit:limit
             offset:offset
            block:^(NSDictionary *JSON, NSError *error) {
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            [questions addObjectsFromArray:[JSON valueForKey:@"question"]];
            //questions = [JSON valueForKey:@"question"];
            loadMore = YES;
            [_myquestionTable reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];                 
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return questions.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"%ld   %lu",(long)indexPath.row, (unsigned long)questions.count);
    if (indexPath.row == (questions.count-1) && loadMore) {
        offset += limit; // load next page
        loadMore = NO; // make loadMore = NO to avoid continuous load requests
        [self loadAllQuestion];
    }
}

-(NSString*) getTimeFormat:(NSString*)time{
    NSString *apm, *time_new, *m, *h_s;
    NSArray *splitTime = [time componentsSeparatedByString:@":"];
    NSInteger h = [[splitTime objectAtIndex:0] integerValue];
    m = [splitTime objectAtIndex:1];
    if (h >= 0 && h < 12) {
        if (h == 0) {
            h = 12;
        }
        apm = @"AM";
    }else{
        if (h != 12) {
            h = h - 12;
        }
        apm = @"PM";
    }
    if (h >= 0 && h < 10) {
        h_s = [NSString stringWithFormat:@"0%ld", (long)h];
    }else{
        h_s = [NSString stringWithFormat:@"%ld", (long)h];
    }
    time_new = [NSString stringWithFormat:@"%@:%@ %@", h_s, m, apm];
    return time_new;
}

- (SwipeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myquestioncell" forIndexPath:indexPath];
    ((UIImageView*)[cell viewWithTag:1]).image = nil;
    ((UILabel*)[cell viewWithTag:2]).text = nil;
    ((UILabel*)[cell viewWithTag:3]).text = nil;
    ((UILabel*)[cell viewWithTag:4]).text = nil;
    ((UILabel*)[cell viewWithTag:5]).hidden = YES;
    if ([questions[indexPath.row]valueForKeyPath:@"user_image"]!=nil) {
        [((UIImageView*)[cell viewWithTag:1]) setImageWithURL:[NSURL URLWithString:[questions[indexPath.row]valueForKeyPath:@"user_image"]]];
    }
    if ([questions[indexPath.row]valueForKeyPath:@"name"]!=nil){
        ((UILabel*)[cell viewWithTag:2]).text = [questions[indexPath.row]valueForKeyPath:@"name"];
    }
    if ([questions[indexPath.row]valueForKeyPath:@"question"]!=nil){
        ((UILabel*)[cell viewWithTag:3]).text = [questions[indexPath.row]valueForKeyPath:@"question"];
    }
    if ([questions[indexPath.row]valueForKeyPath:@"created"]!=[NSNull null]){
        
        NSString *subDateTime = [questions[indexPath.row] valueForKey:@"created"];
        NSString *subDate = [[subDateTime componentsSeparatedByString:@" "] objectAtIndex:0];
        NSString *subTime = [[subDateTime componentsSeparatedByString:@" "] objectAtIndex:1];
        
        df.dateFormat = @"yyyy-MM-dd";
        NSDate *submittedDate = [df dateFromString:subDate];

        df.dateFormat = @"d MMM yyyy";
        
        NSString *submitted = [df stringFromDate:submittedDate];
        NSString *new_time = [self getTimeFormat:subTime];
        
        NSString *r = [NSString stringWithFormat:@"Submitted %@ %@ - %@ response",new_time ,submitted ,[questions[indexPath.row] valueForKeyPath:@"NO_OF_RESPONSE"]];
        ((UILabel*)[cell viewWithTag:4]).text = r;
    }
    
    if ([[questions[indexPath.row]valueForKeyPath:@"new"]boolValue]){
        ((UILabel*)[cell viewWithTag:5]).hidden = NO;
    }else{
        ((UILabel*)[cell viewWithTag:5]).hidden = YES;
    }
    
    cell.canSwipe = YES;
    [cell.forwardBtn addTarget:self action:@selector(forwardMyQuestion:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editBtn addTarget:self action:@selector(addMyQuestion:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(deleteMyQuestion:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
-(void)forwardMyQuestion:(UIButton*)button{
    SwipeCell *cell;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    NSIndexPath *indexPath = [_myquestionTable indexPathForCell:cell];
    NSUInteger question_id = [[questions[indexPath.row] valueForKey:@"id"] integerValue];
    AskNewQuestion *selectController = [self.storyboard instantiateViewControllerWithIdentifier:@"askQuestion"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI forwardQuestion:question_id userID:[[auth valueForKey:@"id"]integerValue] block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            selectController.questionData = JSON;
            [self.navigationController pushViewController:selectController animated:YES];
        }
    }];
    
    
    
}

-(void)addMyQuestion:(UIButton*)button{
    SwipeCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    indexPathDelete = [_myquestionTable indexPathForCell:cell];
    SelectContact *selectController = [self.storyboard instantiateViewControllerWithIdentifier:@"contactSt"];
    selectController.pageInfo = @"My Question";
    selectController.question_id=[questions[indexPathDelete.row] valueForKey:@"id"] ;
    [self.navigationController pushViewController:selectController animated:YES];
}

-(void)deleteMyQuestion:(UIButton*)button{
    SwipeCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    indexPathDelete = [_myquestionTable indexPathForCell:cell];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Do you really want to delete this Question?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES, Delete it", nil];
    [alert show];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //  NSLog(@" row %ld" , (long)indexPathDelete.row);
        NSUInteger question_id = [[questions[indexPathDelete.row] valueForKey:@"id"] integerValue];
        [AppAPI deleteQuestion:question_id userID:[[auth valueForKey:@"id"] integerValue] block:^(NSDictionary *JSON, NSError *error) {
            if(error == nil && [[JSON valueForKeyPath:@"success"] boolValue]){
                [questions removeObjectAtIndex:indexPathDelete.row];
                [_myquestionTable deleteRowsAtIndexPaths:@[indexPathDelete] withRowAnimation:UITableViewRowAnimationNone];
            }else{
                UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Appinionated" message:[JSON valueForKeyPath:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorMsgAlert show];
                [questions removeObjectAtIndex:indexPathDelete.row];
                [_myquestionTable deleteRowsAtIndexPaths:@[indexPathDelete] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        
        
        
    }
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
   // NSLog(@"formatere time %@",time);
    
    
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
   // NSLog(@"%@", questions[indexPath.row]);
    selectedQuestionId = [questions[indexPath.row] valueForKeyPath:@"id"];
    name = [questions[indexPath.row] valueForKeyPath:@"name"];
    [self performSegueWithIdentifier:@"myQuestionSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"myQuestionSegue"]) {
        [segue.destinationViewController setTitle:name];
        ((Question*)segue.destinationViewController).selectedQuestionId = selectedQuestionId;
        ((Question*)segue.destinationViewController).responsePage = @"My Question";
    }
}


@end
