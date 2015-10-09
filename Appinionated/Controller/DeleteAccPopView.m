//
//  DeleteAccPopView.m
//  Appinionated
//
//  Created by Tamal on 12/10/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "DeleteAccPopView.h"
#import "AppAPI.h"
#import "MBProgressHUD.h"
#import "NavMenuController.h"

@interface DeleteAccPopView (){
    NSDictionary *auth;
}

@property (weak, nonatomic) IBOutlet UITextField *emailAddress;
@end

@implementation DeleteAccPopView

- (void)viewDidLoad {
    [super viewDidLoad];
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closePopView:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
//check email validation
-(BOOL) IsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
- (IBAction)confirmDelete:(id)sender {
    [_emailAddress resignFirstResponder];
    
    NSString *emailAddress = _emailAddress.text;
    if ([emailAddress isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please complete email fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![self IsValidEmail:emailAddress] && [emailAddress isEqualToString:[auth valueForKey:@"email"]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Incorrect email address, please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI deleteAccount:emailAddress block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKey:@"success"] boolValue]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"auth"];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"stopInterval"
             object:nil];
            // go back to Login page
            [(NavMenuController*)self.presentingViewController.parentViewController replaceView:@"loginNav"];
        }else{
            UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Account Delete Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMsgAlert show];
        }
    }];
    
    
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
