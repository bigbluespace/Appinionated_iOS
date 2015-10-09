//
//  AskNewQuestion.h
//  Appinionated
//
//  Created by Tamal on 10/27/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AskNewQuestion : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate>
@property NSDictionary *questionData;
@end
