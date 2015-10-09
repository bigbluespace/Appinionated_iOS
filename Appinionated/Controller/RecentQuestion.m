//
//  RecentQuestion.m
//  Appinionated
//
//  Created by Tamal on 10/26/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "RecentQuestion.h"
#import "MBProgressHUD.h"
#import "AppAPI.h"
#import "UIImageView+AFNetworking.h"
#import "Question.h"
#import "SwipeCell.h"
#import "AskNewQuestion.h"
#import "SelectContact.h"


@interface RecentQuestion (){
    NSDictionary *auth;
    NSMutableArray *myQuestions;
    NSDateFormatter *df;
    NSUInteger vote;
    NSString *selectedQuestionId;
    NSString *nameTitle;
    NSIndexPath *indexPathDelete;
    NSUInteger limit;
    NSUInteger offset;
    NSDictionary *q_data;
    BOOL loadMore;
}
@property (weak, nonatomic) IBOutlet UITableView *recentQTable;

@end

@implementation RecentQuestion

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    limit = 10;
    offset = 0;
    loadMore = NO;
    df = [[NSDateFormatter alloc] init];
    myQuestions = [NSMutableArray array];
    vote = 0;
}

-(void) viewDidAppear:(BOOL)animated{
    offset = 0;
    myQuestions = [NSMutableArray array];
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    [self loadRecentQ];
    [_recentQTable reloadData];
}

-(void)loadRecentQ {
   // NSLog(@"Auth name %@",auth);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI recentQ:[[auth valueForKey:@"id"] integerValue]
              limit:limit
             offset:offset
              block:^(NSDictionary *JSON, NSError *error) {
        
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            [myQuestions addObjectsFromArray:[JSON valueForKeyPath:@"question"]];
            loadMore = YES;
            [_recentQTable reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myQuestions.count;
}

- (SwipeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *votes;
    SwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myQCell" forIndexPath:indexPath];
    
    [(UIImageView*)[cell viewWithTag:1] setImageWithURL:[NSURL URLWithString:[myQuestions[indexPath.row] valueForKey: @"image"]]];
    ((UILabel*)[cell viewWithTag:2]).text = [myQuestions[indexPath.row] valueForKey:@"question"];
    
    NSString *subDateTime = [myQuestions[indexPath.row] valueForKey:@"created"];
    NSString *subDate = [[subDateTime componentsSeparatedByString:@" "] objectAtIndex:0];
    
    df.dateFormat = @"yyyy-MM-dd";
   // NSLog(@"date %@", subDate);
    NSDate *submittedDate = [df dateFromString:subDate];
   // NSLog(@"submitted %@", submittedDate);
    df.dateFormat = @"d MMM yyyy";
    NSString *submitted = [df stringFromDate:submittedDate];
  //  NSLog(@"submitted %@", submitted);
    ((UILabel*)[cell viewWithTag:3]).text = [NSString stringWithFormat:@"Submitted %@", submitted];
    if ([myQuestions[indexPath.row] valueForKey:@"NO_OF_RESPONSE"]!=nil) {
        vote = [[myQuestions[indexPath.row] valueForKeyPath:@"NO_OF_RESPONSE"] integerValue];
        votes = [NSString stringWithFormat:@"- %ld Responses", (long)vote];
    }else{
        votes = [NSString stringWithFormat:@"- %ld Response", (long)vote];
    }
    ((UILabel*)[cell viewWithTag:4]).text = votes;
    cell.canSwipe = YES;
    
    [cell.forwardBtn addTarget:self action:@selector(forwardMyQuestion:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.editBtn addTarget:self action:@selector(addMyQuestion:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.deleteBtn addTarget:self action:@selector(deleteQuestion:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

-(void)forwardMyQuestion:(UIButton*)button{
    NSLog(@"Forward ");
    SwipeCell *cell;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    NSIndexPath *indexPath = [_recentQTable indexPathForCell:cell];
    NSUInteger question_id = [[myQuestions[indexPath.row] valueForKey:@"id"] integerValue];
    AskNewQuestion *selectController = [self.storyboard instantiateViewControllerWithIdentifier:@"askQuestion"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI forwardQuestion:question_id userID:[[auth valueForKey:@"id"]integerValue] block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            q_data = JSON;
            //[self performSegueWithIdentifier:@"recentToNewQues" sender:self];
            selectController.questionData = JSON;
            [self.navigationController pushViewController:selectController animated:YES];
        }
    }];
}

-(void)addMyQuestion:(UIButton*)button{
     NSLog(@"Add ");
    SwipeCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    NSIndexPath *indexPath = [_recentQTable indexPathForCell:cell];
    SelectContact *selectController = [self.storyboard instantiateViewControllerWithIdentifier:@"contactSt"];
    selectController.pageInfo = @"My Question Contact Add";
    selectController.question_id=[myQuestions[indexPath.row] valueForKey:@"id"] ;
    [self.navigationController pushViewController:selectController animated:YES];
}

-(void)deleteQuestion:(UIButton*)button{
    SwipeCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    indexPathDelete = [_recentQTable indexPathForCell:cell];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Do you really want to delete this Question?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES, Delete it", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
      //  NSLog(@" row %ld" , (long)indexPathDelete.row);
        NSUInteger question_id = [[myQuestions[indexPathDelete.row] valueForKey:@"id"] integerValue];
        [AppAPI deleteQuestion:question_id userID:[[auth valueForKey:@"id"] integerValue] block:^(NSDictionary *JSON, NSError *error) {
            if(error == nil && [[JSON valueForKeyPath:@"success"] boolValue]){
                [myQuestions removeObjectAtIndex:indexPathDelete.row];
                [_recentQTable deleteRowsAtIndexPaths:@[indexPathDelete] withRowAnimation:UITableViewRowAnimationNone];
            }else{
                UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Appinionated" message:@"This question is no longer existed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [errorMsgAlert show];
                
                [myQuestions removeObjectAtIndex:indexPathDelete.row];
                [_recentQTable deleteRowsAtIndexPaths:@[indexPathDelete] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        
       
        
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%ld   %lu",(long)indexPath.row, (unsigned long)myQuestions.count);
    if (indexPath.row == (myQuestions.count-1) && loadMore) {
        offset += limit; // load next page
        loadMore = NO; // make loadMore = NO to avoid continuous load requests
        [self loadRecentQ];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedQuestionId = [myQuestions[indexPath.row] valueForKeyPath:@"id"];
    //NSLog(@"%@", selectedQuestionId);
    nameTitle = [auth valueForKey:@"name"];
    [self performSegueWithIdentifier:@"recentQuestionSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"recentQuestionSegue"]) {
        [segue.destinationViewController setTitle:nameTitle];
        ((Question*)segue.destinationViewController).selectedQuestionId = selectedQuestionId;
        ((Question*)segue.destinationViewController).responsePage = @"Recent Question";
    }
}


@end
