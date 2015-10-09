//
//  Group.h
//  Appinionated
//
//  Created by Tamal on 10/27/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface Group : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
//@property NSString *question_id;
@property NSString *invite_type;
//@property NSDictionary *question_info;

@property NSString *questionImage;
@property NSString *questionImageThumb;
@property NSDictionary *questionData;

@end
