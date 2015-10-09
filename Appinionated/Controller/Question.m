//
//  HannaMontana.m
//  Appinionated
//
//  Created by Tamal on 10/30/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//
#import "AppAPI.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "Question.h"
#import "PieChart.h"
#import "BarChart.h"

@interface Question (){
    NSDictionary *auth;
    NSMutableArray *answers;
    NSMutableArray *answer_chart;
    BarChart *barchart;
    PieChart *piechart;
   // NSUInteger isAsked;
    NSUInteger question_id;
    NSString *user_id;
    NSArray *responses;
    UITapGestureRecognizer *tapGestureRecognizer;
    BOOL isPieSelected;
    BOOL alreadyAnswered;
    NSString *answeredMsg;
    BOOL showResponse;
    NSDateFormatter *df;
}
@property (weak, nonatomic) IBOutlet UIImageView *questionImage;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIView *topBorder;

@end

@implementation Question

- (void)viewDidLoad {
    [super viewDidLoad];
    answers = [NSMutableArray array];
    df = [[NSDateFormatter alloc] init];
    answer_chart = [NSMutableArray array];
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    NSLog(@"Auth %@", auth);
    
    
    
   /* if ([_responsePage isEqualToString:@"My Question"]) {
        _topBorder.backgroundColor = _questionLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:15.0/255.0 blue:151.0/255.0 alpha:1.0];
        
    }else{
        _topBorder.backgroundColor = _questionLabel.textColor = [UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0];
    }*/
    
    _questionImage.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    isPieSelected = YES;
    alreadyAnswered = NO;
    showResponse = NO;
    [self loadQuestionDetail];
}

-(void)checkAlreadyAnsweredorNot:(NSUInteger)userID questionID: (NSUInteger)questionID{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI alreadyAnswered:userID questionID:questionID block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        alreadyAnswered = [[JSON valueForKeyPath:@"success"] boolValue];
        if (!alreadyAnswered) {
          answeredMsg = [JSON valueForKeyPath:@"msg"];
        }
    }];
}

- (IBAction)reportAbuse:(id)sender {
    //pageInfo = @"aboutReport";
    //[self performSegueWithIdentifier:@"aboutContact" sender:self];
    NSString *emailTitle = @"Inappropriate or Abusive Content";
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:emailTitle];
        [mailController setToRecipients:@[@"support@appinionated.com"]];
        
        NSString *body = [NSString stringWithFormat: @"Question ID: %lu\n\nThis question has been reported as inappropriate or abusive.", (unsigned long)question_id];
        NSLog(@"body %@", body);
        [mailController setMessageBody:body isHTML:NO];
        
        // Present mail view controller on screen
        [self presentViewController:mailController animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(NSString*) getTimeFormat:(NSString*)time{
    NSString *apm, *time_new, *m, *h_s;
    NSArray *splitTime = [time componentsSeparatedByString:@":"];
    NSInteger h = [[splitTime objectAtIndex:0] integerValue];
    m = [splitTime objectAtIndex:1];
    
    //h = h + 8;
    
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

-(void)loadQuestionDetail{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI questionDetail:[_selectedQuestionId integerValue] block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            [_questionImage setImageWithURL:[NSURL URLWithString:[JSON valueForKeyPath:@"question_details.Question.image"]]];
            NSString *question = [JSON valueForKeyPath:@"question_details.Question.question"];
            
           // isAsked = [[JSON valueForKeyPath:@"question_details.Question.is_asked_to_group"] integerValue];
            question_id = [[JSON valueForKeyPath:@"question_details.Question.id"] integerValue] ;
            user_id = [JSON valueForKeyPath:@"question_details.Question.user_id"];
            
            NSString *subDateTime = [JSON valueForKeyPath:@"question_details.Question.created"];//[self setUpdateDate:];
            //_dateLabel.text = submittedDate;
            
            NSString *subDate = [[subDateTime componentsSeparatedByString:@" "] objectAtIndex:0];
            NSString *subTime = [[subDateTime componentsSeparatedByString:@" "] objectAtIndex:1];
            
            NSLog(@"%@", subDateTime);
            NSLog(@"%@", subDate);
            NSLog(@"%@", subTime);
            
            df.dateFormat = @"yyyy-MM-dd";
            NSDate *submittedDate = [df dateFromString:subDate];
            
            df.dateFormat = @"d MMM yyyy";
            
            NSString *submitted = [df stringFromDate:submittedDate];
            NSString *new_time = [self getTimeFormat:subTime];
            
            NSString *new_date = [NSString stringWithFormat:@"%@ %@", new_time, submitted];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                       initWithString:[NSString stringWithFormat:@"%@ %@",question, new_date]];
            
            NSLog(@"Text %@", text);
            
            NSUInteger startIndex = [question length]+1;
            NSInteger strLength = [new_date length];
            NSLog(@"%lu   %ld", (unsigned long)startIndex, (long)strLength);
            
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Open Sans" size:9] range:NSMakeRange(startIndex, strLength)];
            [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.35 alpha:1.0]
                         range:NSMakeRange(startIndex, strLength)];
            //[UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0]
            _questionLabel.attributedText = text;
            
            answers = [JSON valueForKeyPath:@"question_details.Answer"];
            answer_chart = [JSON valueForKey:@"answer_chart"];
            //Check that already answered or not
            NSLog(@"Auth User Id %@",[auth valueForKey:@"id"]);
            [self checkAlreadyAnsweredorNot:[[auth valueForKey:@"id"] integerValue] questionID:question_id];
            [self.tableView reloadData];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

-(NSString*)setUpdateDate:(NSString*) date{
    // Convert string to date object
    NSString *submitted_date;
    //NSLog(@" date %@",date);
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
    
    submitted_date  = [NSString stringWithFormat:@"%@  %@ %@ %@",time,date_day,monthName,Year];
    
    return submitted_date;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (answers.count) {
        return 2+answers.count+responses.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==answers.count) return 230;
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cell_id = @"answerCell";
    
    if (indexPath.row==answers.count) {
        cell_id = @"graphCell";
    }else if (indexPath.row==answers.count+1){
         cell_id = @"viewAllResponse";
    }else if (indexPath.row>answers.count+1){
        cell_id = @"responseCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cell_id forIndexPath:indexPath];
    
    NSArray *ABCD = @[@"A", @"B", @"C", @"D"];
    
    if (indexPath.row <answers.count) {
        ((UILabel*)[cell viewWithTag:1]).text = nil;
        ((UILabel*)[cell viewWithTag:1]).layer.borderColor = nil;
        ((UILabel*)[cell viewWithTag:1]).text =[NSString stringWithFormat:@"  %@. %@", ABCD[indexPath.row], [answers[indexPath.row] valueForKey:@"answer"]];
        NSLog(@"_responsePage %@", _responsePage);
        if ([_responsePage isEqualToString:@"My Question"]) {
            //((UIView*)[cell viewWithTag:101]).backgroundColor = [UIColor colorWithRed:97.0/255.0 green:15.0/255.0 blue:151.0/255.0 alpha:1.0];
            ((UILabel*)[cell viewWithTag:1]).layer.borderColor = [UIColor colorWithRed:97.0/255.0 green:15.0/255.0 blue:151.0/255.0 alpha:1.0].CGColor;
            
        }else{
            //((UIView*)[cell viewWithTag:101]).backgroundColor = [UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0];
            ((UILabel*)[cell viewWithTag:1]).layer.borderColor = [UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0].CGColor;
        }
    }
    
    if (indexPath.row==answers.count){
        UIView *chartContainer = [cell viewWithTag:10];
        [[chartContainer viewWithTag:30] removeFromSuperview];
        [[chartContainer viewWithTag:40] removeFromSuperview];
        CGRect pieFrame = CGRectMake(20.0, 0.0, 210, 210);
        piechart = [[PieChart alloc] initWithFrame:pieFrame];
        piechart.answers = answer_chart;
        
        piechart.tag = 30;
        [chartContainer addSubview:piechart];

        
        CGRect barFrame = CGRectMake(0.0, 0.0, 250, 210);
        barchart = [[BarChart alloc] initWithFrame:barFrame];
        barchart.answers = answer_chart;
        barchart.tag = 40;
        [chartContainer addSubview:barchart];
        
        UIButton *chartToggle = (UIButton*)[cell viewWithTag:20];
        if (isPieSelected) {
            chartToggle.selected = NO;
            barchart.hidden = YES;
            piechart.hidden = NO;
        }else{
            chartToggle.selected = YES;
            barchart.hidden = NO;
            piechart.hidden = YES;
        }
        [chartToggle addTarget:self action:@selector(toggleChart:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (indexPath.row==answers.count+1){
        if ([_responsePage isEqualToString:@"My Question"]) {
            ((UIView*)[cell viewWithTag:104]).backgroundColor = [UIColor colorWithRed:97.0/255.0 green:15.0/255.0 blue:151.0/255.0 alpha:1.0];
            
        }else{
            ((UIView*)[cell viewWithTag:104]).backgroundColor = [UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0];
        }
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleResponse:)];
        [cell.contentView addGestureRecognizer:tapGestureRecognizer];
    }
    ((UIImageView*)[cell viewWithTag:50]).hidden = YES;
    ((UIImageView*)[cell viewWithTag:51]).hidden = YES;
    ((UILabel*)[cell viewWithTag:52]).text = nil;
    ((UILabel*)[cell viewWithTag:53]).text = nil;
    
    
    if (indexPath.row>answers.count+1){
        NSInteger index = indexPath.row-answers.count-2;
        //NSLog(@"%ld", index);
        if ([responses[index] valueForKey:@"answer"] != [NSNull null]) {
            ((UIImageView*)[cell viewWithTag:50]).hidden = NO;
        }else{
            ((UIImageView*)[cell viewWithTag:51]).hidden = NO;
        }
        if ([responses[index] valueForKey:@"name"] != [NSNull null]) {
            ((UILabel*)[cell viewWithTag:52]).text = [responses[index] valueForKey:@"name"];
        }
        
        if ([responses[index] valueForKey:@"answer"] != [NSNull null]) {
            NSPredicate *answer_predicate = [NSPredicate predicateWithFormat:@"answer =  %@", [responses[index] valueForKey:@"answer"]];
            NSArray *answerMatch = [answers filteredArrayUsingPredicate:answer_predicate];
            NSInteger answer_index = [answers indexOfObject:answerMatch[0]];
            
            ((UILabel*)[cell viewWithTag:53]).text = ABCD[answer_index];

        }
        if ([_responsePage isEqualToString:@"My Question"]) {
            ((UIView*)[cell viewWithTag:105]).backgroundColor = [UIColor colorWithRed:97.0/255.0 green:15.0/255.0 blue:151.0/255.0 alpha:1.0];
            
        }else{
            ((UIView*)[cell viewWithTag:105]).backgroundColor = [UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0];
        }
        
    }
    
    return cell;
}

-(void)clearExistingResponse{
    //remove existing response rows from table
    showResponse = NO;
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i=0; i<responses.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:answers.count+2+i inSection:0];
        [indexPaths addObject:indexPath];
    }
    responses = [NSArray array];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

-(void)displayNewResponse{
    showResponse = YES;
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i=0; i<responses.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:answers.count+2+i inSection:0];
        [indexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    //[self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.3];
}

-(void) toggleResponse:(UITapGestureRecognizer*)tap {
    if (!showResponse) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [AppAPI responseQuestion:question_id block:^(NSDictionary *JSON, NSError *error) {
            if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
                [self clearExistingResponse];
                responses = [JSON valueForKey:@"responses"];
                [self displayNewResponse];
                [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.3];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }else{
        [self clearExistingResponse];
    }
}

-(void)scrollToBottom {
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
}

-(IBAction)toggleChart:(UIButton*)btn{
    if (btn.selected) {//currently showing bar chart, switching to pie chart
        btn.selected = NO;
        isPieSelected = YES;
        piechart.hidden = NO;
        barchart.hidden = YES;
    }else{//currently showing pie chart, switching to bar chart
        btn.selected = YES;
        isPieSelected = NO;
        piechart.hidden = YES;
        barchart.hidden = NO;
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //if ([user_id isEqualToString:[auth valueForKey:@"id"]]) {
        
   // }else{
    
    if (alreadyAnswered) {
        
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSLog(@"Question IID --> %@", [answers[indexPath.row] valueForKey:@"question_id"]);
        NSLog(@"Answer IID --> %@", [answers[indexPath.row] valueForKey:@"id"]);
    NSDictionary *parameter = @{
                                @"data[AnswersUser][user_id]" : [auth valueForKey:@"id"],
                                @"data[AnswersUser][question_id]" : [answers[indexPath.row] valueForKey:@"question_id"],
                                @"data[AnswersUser][answer_id]" : [answers[indexPath.row] valueForKey:@"id"]
                                };
    [AppAPI answerQuestion:parameter block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Answered JSON %@", JSON);
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            [self checkAlreadyAnsweredorNot:[[auth valueForKey:@"id"] integerValue] questionID:question_id];
            answer_chart = [JSON valueForKey:@"answer_chart"];
            
            NSIndexPath *i = [NSIndexPath indexPathForRow:answers.count inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[i] withRowAnimation:UITableViewRowAnimationAutomatic];
            responses = [JSON valueForKey:@"response"];
            NSLog(@"%@", responses);
            if (showResponse) {
                [self clearExistingResponse];
            }else{
                [self displayNewResponse];
            }
            
            
        }
    }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"You have already provided a response to this question." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
   // }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row <answers.count;
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
