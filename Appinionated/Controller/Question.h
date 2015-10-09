//
//  HannaMontana.h
//  Appinionated
//
//  Created by Tamal on 10/30/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface Question : UITableViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property NSString *selectedQuestionId;
@property NSString *responsePage;
@end
