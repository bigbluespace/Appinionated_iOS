//
//  Group.m
//  Appinionated
//
//  Created by Tamal on 10/27/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "Group.h"
#import "AppAPI.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "Colleagues.h"
#import "SwipeCell.h"
#import "SelectContact.h"
#import "QuestionShare.h"

#define kAlertViewOne 1
#define kAlertViewTwo 2
#define kAlertViewThree 3

@interface Group (){
    NSDictionary *auth;
    NSMutableArray *myGroup;
    NSMutableDictionary *group_data;
    NSIndexPath *indexPathDelete;
    NSIndexPath *indexPathUpdate;
    NSMutableArray *gr;
    NSMutableDictionary *selectedGroup;
    NSString *group_name;
    NSArray *contact_email;
    NSArray *contact_sms;
    
    NSString *question_id;
    NSDictionary *questionInfo;
    
}
@property (weak, nonatomic) IBOutlet UITableView *groupTable;

@end

@implementation Group

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    //[self loadGroups];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    group_data = [[NSMutableDictionary alloc] init];
    [self loadGroups];
}

-(void)loadGroups{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI showGroupList:[[auth valueForKey:@"id"] integerValue] block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
           // NSLog(@"%@",JSON);
            myGroup = [NSMutableArray array];
            for (NSDictionary *mygroup in [JSON valueForKeyPath:@"all_groups"]) {
                NSMutableDictionary *singleGroup = [NSMutableDictionary new];
                NSMutableDictionary *Building = [[NSMutableDictionary alloc] initWithDictionary:[mygroup valueForKey:@"Mygroup"]];
                [singleGroup setValue:Building forKey:@"Mygroup"];
                
                NSMutableArray *users = [NSMutableArray new];
                for (NSDictionary *user in [mygroup valueForKey:@"User"]) {
                    NSMutableDictionary *mutableuser = [[NSMutableDictionary alloc] initWithDictionary:user];
                    [users addObject:mutableuser];
                }
                [singleGroup setValue:users  forKey:@"User"];
                // NSLog(@"Single Group  %@",singleGroup);
                [myGroup  addObject:singleGroup];
            }
            [_groupTable reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
    ((UIImageView*)[cell viewWithTag:1]).image = nil;
    ((UILabel*)[cell viewWithTag:2]).text = nil;
    ((UILabel*)[cell viewWithTag:3]).text = nil;
    if ([myGroup[indexPath.row] valueForKeyPath:@"Mygroup.image"] != [NSNull null]) {
        [((UIImageView*)[cell viewWithTag:1]) setImageWithURL:[NSURL URLWithString:[myGroup[indexPath.row] valueForKeyPath:@"Mygroup.image"]]];
    }
    if ([myGroup[indexPath.row] valueForKeyPath:@"Mygroup.name"] != [NSNull null]) {
        ((UILabel*)[cell viewWithTag:2]).text = [myGroup[indexPath.row] valueForKeyPath:@"Mygroup.name"];
    }
    if ([[myGroup[indexPath.row] valueForKey:@"User"] count] > 0) {

        NSArray *users = [myGroup[indexPath.row] valueForKey:@"User"];
        NSMutableArray *user_names = [NSMutableArray array];
        for (id user in users) {
            [user_names addObject:[user valueForKey:@"name"]];
        }
        NSString *username = [user_names componentsJoinedByString:@","];
      //  NSLog(@"%@", username);
        ((UILabel*)[cell viewWithTag:3]).text = username;
    }
    cell.canSwipe = YES;
    UIButton *editBtn = cell.editBtn;
    [editBtn addTarget:self action:@selector(editGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteBtn = cell.deleteBtn;
    [deleteBtn addTarget:self action:@selector(deleteGroup:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (IBAction)newGroup:(id)sender {
    selectedGroup = nil;
    [self performSegueWithIdentifier:@"groupSegue" sender:self];
}

-(void)editGroup:(UIButton*)button {
    SwipeCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    indexPathUpdate = [_groupTable indexPathForCell:cell];
    selectedGroup = myGroup[indexPathUpdate.row] ;
    [self performSegueWithIdentifier:@"groupSegue" sender:self];
    
}

-(void)deleteGroup:(UIButton*)button {
    SwipeCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // iOS 7
        cell = (SwipeCell*)button.superview.superview.superview.superview;
    } else { // iOS 8
        cell = (SwipeCell*)button.superview.superview.superview;
    }
    indexPathDelete = [_groupTable indexPathForCell:cell];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Do you really want to delete this Group?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES, Delete it", nil];
    alert.tag = kAlertViewOne;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertViewOne) {
        if (buttonIndex == 1) {
            //NSLog(@" row %ld" , (long)indexPathDelete.row);
            NSUInteger index = [[myGroup[indexPathDelete.row] valueForKeyPath:@"Mygroup.id"] integerValue];
            [AppAPI deleteGroup:[[auth valueForKey:@"id"] integerValue] groupID:index block:^(NSDictionary *JSON, NSError *error) {
                
            }];
            
            [myGroup removeObjectAtIndex:indexPathDelete.row];
            [_groupTable deleteRowsAtIndexPaths:@[indexPathDelete] withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }else if(alertView.tag == kAlertViewTwo){
        if (contact_sms.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"%@", indexPath);
    if ([_invite_type isEqualToString:@"Invite Group"]) {
        
        [self askQuestionDataSaveProcess:indexPath];
    }else{
        
        group_data = [myGroup[indexPath.row] valueForKey:@"Mygroup"];
        [self performSegueWithIdentifier:@"groupDetail" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)askQuestionDataSaveProcess:(NSIndexPath*)indexPath{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [AppAPI askQuestion:_questionData constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (_questionImage != nil && _questionImageThumb != nil) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:_questionImage] name:@"data[Question][imagex]" fileName:@"question.jpg" mimeType:@"image/jpeg" error:nil];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:_questionImageThumb] name:@"data[Question][thumb]" fileName:@"questionThumb.jpg" mimeType:@"image/jpeg" error:nil];
        }
    } block:^(NSDictionary *JSON, NSError *error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            // next page: select contacts or group
            question_id = [JSON valueForKeyPath:@"question.questin_id"];
            questionInfo = [JSON valueForKeyPath:@"question"];
            BOOL firstTime = [[JSON valueForKeyPath:@"question.first_time"] boolValue];
            
            if (firstTime) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"If a contact does not have the Appinionated App a text message is sent to this person according to your call plan" delegate:self cancelButtonTitle:@"No, cancel" otherButtonTitles:@"Yes, go for it",nil];
                alert.tag = kAlertViewThree;
                [alert show];
            }
             [self groupInviteRequest:indexPath questionId:question_id];
            
            
        } else {
            UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[JSON valueForKeyPath:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMsgAlert show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1 && alertView.tag == kAlertViewThree) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sms_email_permission"];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sms_email_permission"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)groupInviteRequest:(NSIndexPath*)indexPath questionId:(NSString*)questionId{
    NSDictionary *params = @{
                             @"data[QuestionsUser][mygroup_id]" : [myGroup[indexPath.row] valueForKeyPath:@"Mygroup.id"]
                             };
    [AppAPI inviteGroups:params questionID:[questionId integerValue] userID:[[auth valueForKey:@"id"] integerValue] block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            group_name = [myGroup[indexPath.row] valueForKeyPath:@"Mygroup.name"];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"clearForm"
             object:nil];
            
            NSInteger email_count = [[JSON valueForKeyPath:@"email_user"] count];
            NSInteger sms_count = [[JSON valueForKeyPath:@"sms_user"] count];
            
            contact_email = [JSON valueForKeyPath:@"email_user"];
            contact_sms = [JSON valueForKeyPath:@"sms_user"];
            
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sms_email_permission"]) {
                
                if(email_count > 0 && sms_count == 0){
                    [self sendEmail:contact_email];
                }
                
                if (email_count == 0 && sms_count > 0) {
                    [self sendSMS:contact_sms];
                }
                
                if (email_count > 0 && sms_count > 0) {
                    [self sendEmail:contact_email];
                }
                
                if (email_count == 0 && sms_count == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            
            [self performSegueWithIdentifier:@"questionShare" sender:self];
        }
        
    }];
}

#pragma mark-Email Interface

-(void)sendEmail:(NSArray*)receipents{
    NSString *emailTitle = @"Appinionated";
    NSString *itunes_url = @"https://itunes.apple.com/app/id969045081";
    NSString *mailBody = [NSString stringWithFormat:@"%@ has asked you a question on the Appinionated App. Download it today from: \n %@", [auth valueForKey:@"name"], [NSURL URLWithString:itunes_url]];
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:emailTitle];
        [mailController setToRecipients:receipents];
        [mailController setMessageBody:mailBody isHTML:NO];
        
        // Present mail view controller on screen
        [self presentViewController:mailController animated:YES completion:nil];
    }else{
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please set up your account to send Email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        warningAlert.tag = kAlertViewTwo;
        [warningAlert show];
//        if (contact_sms.count == 0) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
        
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
    
    [self dismissViewControllerAnimated:NO completion:^(void){
        if ([contact_sms count] > 0) {
            [self sendSMS:contact_sms];
        }
    }];
   // [self.navigationController popViewControllerAnimated:NO];
    
}

#pragma mark-sms UI Interface

-(void) sendSMS:(NSArray*)receipents{
    NSString *itunes_url = @"https://itunes.apple.com/app/id969045081";
    NSString *messageBody = [NSString stringWithFormat:@"%@ has asked you a question on the Appinionated App. Download it today from %@", [auth valueForKey:@"name"], [NSURL URLWithString:itunes_url]];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]){
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:receipents];
        [messageController setBody:messageBody];
        [self presentViewController:messageController animated:YES completion:nil];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
    //[self.navigationController popViewControllerAnimated:NO];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"groupDetail"]) {//Group Detail
        [segue.destinationViewController setTitle:[group_data valueForKey:@"name"]];
        ((Colleagues*)segue.destinationViewController).group_data = group_data;
    }
    if ([segue.identifier isEqualToString:@"groupSegue"]) {//Group Detail
        if (selectedGroup == nil) {
            [segue.destinationViewController setTitle:@"New Group"];
        }else{
            [segue.destinationViewController setTitle:@"Update Group"];
            ((SelectContact*)segue.destinationViewController).group_data = selectedGroup;
        }
       
    }
    if ([segue.identifier isEqualToString:@"questionShare"]) {
        ((QuestionShare*)segue.destinationViewController).name = group_name;
        ((QuestionShare*)segue.destinationViewController).question_info = questionInfo;
    }
    
}


@end
