//
//  ShareOverlay.h
//  Appinionated
//
//  Created by Tamal on 12/14/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>

@interface ShareOverlay : UIViewController <MFMessageComposeViewControllerDelegate>
@property NSDictionary *question_info;
@end
