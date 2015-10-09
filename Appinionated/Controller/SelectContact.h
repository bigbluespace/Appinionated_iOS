//
//  SelectContact.h
//  Appinionated
//
//  Created by Tamal on 11/10/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface SelectContact : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@property NSArray *existingFamilyMembers;
@property NSString *question_id;
@property NSMutableDictionary *group_data;
//@property NSDictionary *question_info;
@property NSString *pageInfo;

@property NSString *questionImage;
@property NSString *questionImageThumb;
@property NSDictionary *questionData;

@end
