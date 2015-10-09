//
//  NavMenuController.h
//  Appinionated
//
//  Created by Tamal on 10/29/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface NavMenuController : UIViewController

-(void)replaceView:(NSString*)identifier;
-(IBAction)leftMenuAction:(UIButton*)btn;

@end
