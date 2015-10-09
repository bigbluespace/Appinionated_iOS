//
//  SelectContact.m
//  Appinionated
//
//  Created by Tamal on 11/10/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "SelectContact.h"
#import "AppAPI.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Resize.h"
#import "QuestionShare.h"
#import "MBProgressHUD.h"
#import "NavMenuController.h"

#define kAlertViewOne 1
#define kAlertViewTwo 2
#define kAlertViewThree 3

@interface SelectContact (){
    NSMutableArray *allContacts;
    NSMutableArray *alphabetArray;
    NSMutableArray *selectedContacts;
    NSDictionary *auth;
    NSString *groupImagePath;
    NSString *groupImageThumbPath;
    NSMutableArray *deletedUsers;
    NSMutableArray *recommandedFriendEmails;
    NSMutableArray *recommandedFriendSMS;
    NSArray *contact_email;
    NSArray *contact_sms;
    NSString *message;
    NSArray *alphabetLetters;
    BOOL contact_page;
    NSUInteger global_sms_counter;
    NSDictionary *quest_data;
    NSString *ques_id;
    NSDictionary *questionInfo;
}
@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (strong, nonatomic) IBOutlet UITableView *contactsTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *createGroupBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadImgBtn;

@end

@implementation SelectContact

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSLog(@"%@  %@",_pageInfo, _question_id);
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 38)];
    
    _groupName.leftView = leftView;
    _groupName.leftViewMode = UITextFieldViewModeAlways;
    
    deletedUsers = [NSMutableArray array];
    recommandedFriendEmails = [NSMutableArray array];
    recommandedFriendSMS = [NSMutableArray array];
    
    global_sms_counter = 0;
    
    contact_page = NO;
    
    if (_group_data != nil) {
        _groupName.text = [_group_data valueForKeyPath:@"Mygroup.name"];
        [_createGroupBtn setTitle:@"Update Group" forState:UIControlStateNormal];
        _createGroupBtn.enabled = YES;
    }
    
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:240.0/255.0 green:171.0/255.0 blue:26.0/255.0 alpha:1.0]];
    
    alphabetArray = [NSMutableArray array];
    allContacts = [NSMutableArray array];
    selectedContacts = [NSMutableArray array];
    
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    NSString *itunes_url = @"https://itunes.apple.com/app/id969045081";
    message = [NSString stringWithFormat:@"%@ has asked you a question on Appinionated. Download the App today.Download it today from: \n %@", [auth valueForKey:@"name"],[NSURL URLWithString:itunes_url]];
    
    
    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Retrieve Contact List" message: @"You must allow Appinionated app to access your Contacts." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
        [cantAddContactAlert show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        [self loadAllContacts:addressBook];
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    //4
                    [cantAddContactAlert show];
                    return;
                }
                //5
                [self loadAllContacts:addressBook];
            });
        });
    }
}

-(void)processContacts
{
    
    //[alphabetArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    //sorting array in ascending array
    NSMutableArray *contacts = [NSMutableArray array];
    NSMutableArray *AtoZContacts = [[NSMutableArray alloc] initWithArray:allContacts];
    
    for (NSString *initial in alphabetLetters) {
        
        if ([initial isEqualToString:@"#"]) {
            [contacts addObject:AtoZContacts];
        }else{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c]  %@", initial];
            NSMutableArray *mutableContacts = [[NSMutableArray alloc] initWithArray:[allContacts filteredArrayUsingPredicate:predicate]];
            [contacts addObject:mutableContacts];
            [AtoZContacts removeObjectsInArray:mutableContacts];
        }
        
    }
    allContacts = contacts;
    // NSLog(@"All--->%@", allContacts);
}

- (void)loadAllContacts:(ABAddressBookRef)addressBook {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        
        
        for(int i = 0; i < numberOfPeople; i++){
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            
            NSString *name;
            
            if ([firstName length] && [lastName length]) {
                name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            } else if ([firstName length]){
                name = firstName;
            } else if ([lastName length]){
                name= lastName;
            } else {
                name = @"";
            }
            
            // Get the e-mail addresses as a multi-value property.
            ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            NSMutableArray *emails = [NSMutableArray array];
            
            for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
                CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
                NSString *email = (__bridge NSString *)(currentEmailValue);
                CFRelease(currentEmailValue);
                
                if (email != nil) {
                    [emails addObject:email];
                    
                }
            }
            
            if (name.length == 0 && emails.count) {
                name = emails[0];
            }
            CFRelease(emailsRef);
            
            // Get the phone numbers as a multi-value property.
            ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            NSMutableArray *phones = [NSMutableArray array];
            
            for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
                CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
                NSString *phone = (__bridge NSString *)(currentPhoneValue);
                CFRelease(currentPhoneValue);
                
                if (phone != nil) {
                    
                    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"- ()"];
                    phone = [[phone componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
                    
                    //[allContacts addObject: @{ @"name" : name, @"email" : email} ];
                    [phones addObject:phone];
                    
                }
            }
            if (name.length == 0 && phones.count) {
                name = phones[0];
            }
            CFRelease(phonesRef);
            if (name.length == 0) {
                continue;
            }
            
            [allContacts addObject: @{ @"name" : name, @"emails" : emails, @"phones": phones} ];
        }
        allContacts = (NSMutableArray*)[allContacts sortedArrayUsingComparator:^(id obj1, id obj2) {
            return [[obj1 valueForKey:@"name"] localizedCaseInsensitiveCompare:[obj2 valueForKey:@"name"]];
        }];
        alphabetLetters = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
        [self processContacts];
        [_contactsTable reloadData];
        
        
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return alphabetLetters.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [allContacts[section] count];
}
//Start Editing
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return nil;
    } else {
        // return your normal return
        return alphabetLetters[section];
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return alphabetLetters;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return index;
}

//End Editing
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    NSString *contact_name = [allContacts[indexPath.section][indexPath.row] valueForKey:@"name"];
    NSMutableArray *existingGroup = [_group_data valueForKey:@"User"];
    
    //Edit Group
    if (existingGroup != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name =  %@", contact_name];
        NSArray *match = [existingGroup filteredArrayUsingPredicate:predicate];
        if (match.count) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_contactsTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            NSMutableDictionary *contact = [[NSMutableDictionary alloc] initWithDictionary:allContacts[indexPath.section][indexPath.row]];
            
            [contact setValue:[match[0] valueForKey:@"mygroupsuser_id"] forKey:@"mygroupsuser_id"];
            
            [allContacts[indexPath.section] replaceObjectAtIndex:indexPath.row withObject:contact];
            
            //[selectedContacts addObject:contact];
        }
    }
    cell.textLabel.text= contact_name;
    
    if ([selectedContacts containsObject:allContacts[indexPath.section][indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([allContacts[indexPath.section][indexPath.row] valueForKey:@"mygroupsuser_id"]) {
        NSLog(@"mygroupsuser_id-->%@",[allContacts[indexPath.section][indexPath.row] valueForKey:@"mygroupsuser_id"]);
        
        [deletedUsers removeObject:[allContacts[indexPath.section][indexPath.row] valueForKey:@"mygroupsuser_id"]];
        
    }else{
        [selectedContacts addObject:allContacts[indexPath.section][indexPath.row]];
        NSLog(@"selectedContacts-->%@",selectedContacts);
        
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _doneBtn.enabled = YES;
    if (_groupName.text != nil && _group_data == nil) {
        _createGroupBtn.enabled = YES;
    }
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([allContacts[indexPath.section][indexPath.row] valueForKey:@"mygroupsuser_id"]) {
        NSLog(@"mygroupsuser_id-->%@",[allContacts[indexPath.section][indexPath.row] valueForKey:@"mygroupsuser_id"]);
        [deletedUsers addObject:[allContacts[indexPath.section][indexPath.row] valueForKey:@"mygroupsuser_id"]];
    }else{
        [selectedContacts removeObject:allContacts[indexPath.section][indexPath.row]];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    _doneBtn.enabled = selectedContacts.count > 0;
    if (_group_data == nil) {
        _createGroupBtn.enabled = selectedContacts.count > 0;
    }
    
    
}


-(NSDictionary*)processData:(NSString*)model{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableDictionary *dataReport = [NSMutableDictionary dictionary];
    // NSMutableDictionary *recommanded = [NSMutableDictionary dictionary];
    int counter = 0;
    NSLog(@"NEw Selected Contacts%@", selectedContacts);
    for (NSDictionary *contact in selectedContacts) {
        NSLog(@"New Selected Contact %d %@",counter, contact);
        NSString *name =[contact valueForKey:@"name"];
        NSArray *phones = [contact valueForKey:@"phones"];
        NSArray *emails = [contact valueForKey:@"emails"];
        //[recommandedFriendSMS addObjectsFromArray:phones];
        //[recommandedFriendEmails addObjectsFromArray:emails];
        NSInteger max = MAX([phones count], [emails count]);
        for (int i=0; i<max; i++) {
            [data setValue:name forKey:[NSString stringWithFormat:@"data[%@][name][%d]", model, counter]];
            if(phones.count > i){
                [data setValue:phones[i] forKey:[NSString stringWithFormat:@"data[%@][mobile][%d]", model, counter]];
                [recommandedFriendSMS addObject:phones[i]];
                NSLog(@"phones %d %@", i, phones[i]);
            }else{
                [data setValue:[NSNull null] forKey:[NSString stringWithFormat:@"data[%@][mobile][%d]", model, counter]];
            }
            if(emails.count > i){
                [data setValue:emails[i] forKey:[NSString stringWithFormat:@"data[%@][email][%d]", model, counter]];
                [dataReport setValue:emails[i] forKey:[NSString stringWithFormat:@"data[%@][email][%d]", model, counter]];
                [recommandedFriendEmails addObject:emails[i]];
                NSLog(@"emails %d %@", i, emails[i]);
            }else{
                [data setValue:[NSNull null] forKey:[NSString stringWithFormat:@"data[%@][email][%d]", model, counter]];
            }
            counter++;
        }
    }
    
    NSLog(@"%@ \n %@", recommandedFriendSMS, recommandedFriendEmails);
    
    if (deletedUsers.count > 0) {
        counter = 0;
        for (NSString *mygroupsuser_id in deletedUsers) {
            [data setValue:mygroupsuser_id forKey:[NSString stringWithFormat:@"data[MygroupsUser][id][%d]", counter]];
            counter++;
        }
    }
    
    
    if ([_pageInfo isEqualToString:@"aboutReport"]) {
        return dataReport;
    } if([_pageInfo isEqualToString:@"aboutRecommanded"]){
        return @{@"emails": recommandedFriendEmails, @"sms": recommandedFriendSMS};
    }else{
        return data;
    }
    
}



- (IBAction)done:(id)sender {
    
   // NSLog(@" selectedContacts %@",selectedContacts);
    
    NSDictionary *data = [NSDictionary dictionary];

    if ([_pageInfo isEqualToString:@"questionContact"] || [_pageInfo isEqualToString:@"My Question"]) {
        
        [self askQuestionDataSaveProcess:data];
        
    }
    if ([_pageInfo isEqualToString:@"My Question Contact Add"]) {
        
        [self contactInviteRequest:data questionId:_question_id];
    }
    
    NSLog(@"Page Info %@", _pageInfo);
    if ([_pageInfo isEqualToString:@"aboutRecommanded"]) {
        [self processData:@" "];
        if (recommandedFriendEmails.count > 0) {
            [self sendEmail:recommandedFriendEmails body:message];
        }
        global_sms_counter = recommandedFriendSMS.count;
        if(recommandedFriendSMS.count > 0){
            [self sendSMS:recommandedFriendSMS body:message];
        }
        if (recommandedFriendSMS.count==0 && recommandedFriendEmails.count==0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Contact Number or Mail Found." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        //[self.navigationController popViewControllerAnimated:NO];
    }
    if ([_pageInfo isEqualToString:@"aboutReport"]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        data = [self processData:@"User"];
        
        [AppAPI reportAbuse:data block:^(NSDictionary *JSON, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[JSON valueForKeyPath:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
}

-(void)askQuestionDataSaveProcess:(NSDictionary*)data{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [AppAPI askQuestion:_questionData constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (_questionImage != nil && _questionImageThumb != nil) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:_questionImage] name:@"data[Question][imagex]" fileName:@"question.jpg" mimeType:@"image/jpeg" error:nil];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:_questionImageThumb] name:@"data[Question][thumb]" fileName:@"questionThumb.jpg" mimeType:@"image/jpeg" error:nil];
        }
    } block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
       // NSLog(@" App Error %@",error.localizedDescription);
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            // next page: select contacts or group
            ques_id = [JSON valueForKeyPath:@"question.questin_id"];
            questionInfo = [JSON valueForKeyPath:@"question"];
            BOOL firstTime = [[JSON valueForKeyPath:@"question.first_time"] boolValue];
            quest_data = data;
            if (firstTime) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"If a contact does not have the Appinionated App a text message is sent to this person according to your call plan" delegate:self cancelButtonTitle:@"No, cancel" otherButtonTitles:@"Yes, go for it",nil];
                alert.tag = kAlertViewThree;
                [alert show];
            }else{
                [self contactInviteRequest:data questionId:ques_id];
            }
            
            
        } else if([error.localizedDescription isEqualToString:@"cancelled"]) {
            UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The question is no longer existed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMsgAlert show];
            if([_pageInfo isEqualToString:@"My Question"]){
                UIButton *dummyBtn = [[UIButton alloc] init];
                dummyBtn.tag = 2;
                [(NavMenuController*)self.navigationController.parentViewController leftMenuAction:dummyBtn];
            }else if([_pageInfo isEqualToString:@"Recent Question"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }else{
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
    [self contactInviteRequest:quest_data questionId:ques_id];
}

-(void) contactInviteRequest:(NSDictionary*)data questionId:(NSString*)questionId{
    data = [self processData:@"QuestionsUser"];
    [AppAPI inviteContacts:data questionID:[questionId integerValue] userID:[[auth valueForKey:@"id"] integerValue] block:^(NSDictionary *JSON, NSError *error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"clearForm"
             object:nil];
            NSInteger email_count = [[JSON valueForKeyPath:@"email_user"] count];
            NSInteger sms_count = [[JSON valueForKeyPath:@"sms_user"] count];
            
            contact_email = [JSON valueForKeyPath:@"email_user"];
            contact_sms = [JSON valueForKeyPath:@"sms_user"];
            global_sms_counter = contact_sms.count;
            contact_page = YES;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sms_email_permission"]) {
                if(email_count > 0 && sms_count == 0){
                    [self sendEmail:contact_email body:message];
                }
                
                if (email_count == 0 && sms_count > 0) {
                    [self sendSMS:contact_sms body:message];
                }
                
                if (email_count > 0 && sms_count > 0) {
                    [self sendEmail:contact_email body:message];
                }
                
                if (email_count == 0 && sms_count == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                    NSLog(@"No SMS or Email");
                }
            }
            [self performSegueWithIdentifier:@"shareQuestion" sender:self];
        }
    }];
}


//**********About Page***********//
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (global_sms_counter > 0) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}

#pragma mark- Send Email Interface
-(void)sendEmail:(NSArray*)receipents body:(NSString*)mailBody{
    NSString *emailTitle = @"Appinionated";
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
        warningAlert.tag = kAlertViewOne;
        [warningAlert show];
//        if (global_sms_counter == 0) {
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
    if (contact_page) {
        [self dismissViewControllerAnimated:NO completion:^(void){
            if ([contact_sms count] > 0) {
                [self sendSMS:contact_sms body:message];
            }
        }];
    }else{
        [self dismissViewControllerAnimated:NO completion:^(void){
            if (recommandedFriendSMS.count > 0) {
                [self sendSMS:recommandedFriendSMS body:message];
            }else{
                [self.navigationController popViewControllerAnimated:NO];
            }
        }];
    }
    
}

#pragma mark - Send SMS UI Interface
-(void) sendSMS:(NSArray*)receipents body:(NSString*)messageBody{
    NSLog(@"%ld", (long)[receipents[0] integerValue]);
    
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
    if (!contact_page) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    //
}


//************ Add New Group ***********//
- (IBAction)addImage:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Image"
                                                             delegate:self
                                                    cancelButtonTitle:@"cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Gallery", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showCameraImagePicker];
    } else if (buttonIndex == 1) {
        [self showGalleryImagePicker];
    }
}


//take a photo from camera
- (void)showCameraImagePicker {
#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Simulator" message:@"Camera not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#elif TARGET_OS_IPHONE
    UIImagePickerController *cameraImagePicker = [[UIImagePickerController alloc] init];
    cameraImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraImagePicker.delegate = self;
    cameraImagePicker.allowsEditing = NO;
    cameraImagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:cameraImagePicker animated:YES completion:nil];
#endif
}
- (void)showGalleryImagePicker{
    UIImagePickerController *galleryImagePicker = [[UIImagePickerController alloc] init];
    galleryImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    galleryImagePicker.delegate = self;
    galleryImagePicker.allowsEditing = NO;
    [self presentViewController:galleryImagePicker animated:YES completion:nil];
}

#pragma mark - image/camera picker delegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    // Extract image from the picker / camera
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    groupImagePath = nil;
    groupImageThumbPath = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *originalImage = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
        
        // resize image to max 1000px on one side
        //UIImage *image = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1000,1000) interpolationQuality:kCGInterpolationHigh];
        
        // resize to 420x420
        UIImage *image = [originalImage thumbnailImage:420 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        
        // generate thumb photo
        UIImage *thumb = [originalImage thumbnailImage:244 transparentBorder:0 cornerRadius:122 interpolationQuality:kCGInterpolationHigh];
        
        
        // [_addImageBtn setImage:thumb forState:UIControlStateNormal];
        // [_addImageBtn setTitle:@"" forState:UIControlStateNormal];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        groupImagePath = [self writeMedia:imageData fileName:@"group.jpg"];
        
        NSData *thumbData = UIImageJPEGRepresentation(thumb, 1.0);
        groupImageThumbPath = [self writeMedia:thumbData fileName:@"groupThumb.jpg"];
        NSLog(@"groupImagePath %@ groupImageThumbPath %@", groupImagePath, groupImageThumbPath);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (NSString*)writeMedia:(NSData*)mediaData fileName:(NSString*)fileName {
    //NSString *fileName = [NSString stringWithFormat:@"%@.%@", [[NSUUID UUID] UUIDString], extension];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *mediaPath = [tmpDirectory stringByAppendingPathComponent:fileName];
    
    if (![mediaData writeToFile:mediaPath atomically:YES]){
        NSLog((@"Failed to cache media data to disk"));
        return nil;
    }
    NSLog(@"saved image %@", mediaPath);
    
    return mediaPath;
}

- (IBAction)validateGroupName:(UITextField*)textfield {
    if (textfield.text.length > 0) {
        _createGroupBtn.enabled = YES;
    }else{
        _createGroupBtn.enabled = YES;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)textFieldKeyboardDis:(UITextField*)textfield {
    [textfield resignFirstResponder];
}


- (IBAction)createGroup:(id)sender {
    if([_groupName.text isEqualToString:@""]){
        UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter group name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorMsg show];
        return;
    }
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[self processData:@"MygroupsUser"]];
    [data setValue:_groupName.text forKey:@"data[Mygroup][name]"];
    
    if (_group_data != nil) {
        [AppAPI updateGroup:data
                     userID:[[auth valueForKey:@"id"] integerValue]
                    groupID:[[_group_data valueForKeyPath:@"Mygroup.id"] integerValue]
  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      if (groupImagePath != nil && groupImageThumbPath != nil) {
          [formData appendPartWithFileURL:[NSURL fileURLWithPath:groupImageThumbPath] name:@"data[Mygroup][imagex]" fileName:@"groupThumb.jpg" mimeType:@"image/jpeg" error:nil];
      }
  } block:^(NSDictionary *JSON, NSError *error) {
      if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
          [self.navigationController popViewControllerAnimated:YES];
          NSFileManager *fileManager = [NSFileManager defaultManager];
          [fileManager removeItemAtPath:groupImagePath error:nil];
          [fileManager removeItemAtPath:groupImageThumbPath error:nil];
      }
      
  }];
    }else{
        [AppAPI createGroup:data
                     userID:[[auth valueForKey:@"id"] integerValue]
  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      if (groupImagePath != nil && groupImageThumbPath != nil) {
          [formData appendPartWithFileURL:[NSURL fileURLWithPath:groupImageThumbPath] name:@"data[Mygroup][imagex]" fileName:@"groupThumb.jpg" mimeType:@"image/jpeg" error:nil];
      }
  }
                      block:^(NSDictionary *JSON, NSError *error) {
                          if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
                              NSLog(@" New Group %@", JSON);
                              [self.navigationController popViewControllerAnimated:YES];
                              NSFileManager *fileManager = [NSFileManager defaultManager];
                              [fileManager removeItemAtPath:groupImagePath error:nil];
                              [fileManager removeItemAtPath:groupImageThumbPath error:nil];
                          }
                      }];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shareQuestion"]) {
        ((QuestionShare*)segue.destinationViewController).name = @"Your Contacts";
        ((QuestionShare*)segue.destinationViewController).question_info = questionInfo;
    }
}


@end
