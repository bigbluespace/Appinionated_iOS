//
//  Login.m
//  Appinionated
//
//  Created by Tamal on 10/26/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//
#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#import "Login.h"
#import "AppAPI.h"
#import "MBProgressHUD.h"
#import "NavMenuController.h"
#import "Signup.h"

@interface Login (){
    NSMutableArray *textFields;
    NSUInteger currentIndex;
    CGFloat PORTRAIT_KEYBOARD_HEIGHT, origin;
    NSObject *fbLoginInfo;
    NSString *userImageURL;
}
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIToolbar *kbToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *kbTitle;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@end

@implementation Login

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    
    _password.layer.borderColor=_email.layer.borderColor=[UIColor darkGrayColor].CGColor;
    //[UIColor colorWithWhite:229.0/255.0 alpha:1.5].CGColor;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    PORTRAIT_KEYBOARD_HEIGHT = IPAD ? 318 : 270;
    textFields = [NSMutableArray array];
    [self perpareTextFieldsInputViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    fbLoginInfo = user;
    userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectID]];
    //NSLog(@"permissions::%@",FBSession.activeSession.permissions);
    
    NSString *birthday =user.birthday;
    if(user.birthday != nil){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        
        NSDate *dob = [dateFormat dateFromString:birthday];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        birthday = [dateFormat stringFromDate:dob];
    }else{
        birthday = @"1996-01-01";
    };
    
    NSLog(@"Fb login %@", [user objectForKey:@"id"]);
    NSLog(@"Fb login %@", [user objectForKey:@"email"]);
    NSLog(@"Fb login %@", user.name);
    NSLog(@"Fb login %@", birthday);
    NSLog(@"Fb login %@", [user objectForKey:@"gender"]);
    NSLog(@"Fb login %@", userImageURL);
    
    NSString *deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    NSLog(@"Fb login %@", deviceToken);
    
    NSDictionary *params;
    
    if (deviceToken == nil) {
        params =@{
                  @"data[User][fbid]" : [user objectForKey:@"id"],
                  @"data[User][fb_email]": [user objectForKey:@"email"],
                  @"data[User][fb_name]": user.name,
                  @"data[User][fb_dob]": birthday,
                  @"data[User][fb_gender]": [user objectForKey:@"gender"],
                  @"data[User][fb_image]" : userImageURL,
                  @"data[DeviceToken][device_type]":@"ios",
                  @"data[DeviceToken][device_token]" : @"",
                  @"data[DeviceToken][stage]":@"production"
                  };
    }else{
        params =@{
                  @"data[User][fbid]" : [user objectForKey:@"id"],
                  @"data[User][fb_email]": [user objectForKey:@"email"],
                  @"data[User][fb_name]": user.name,
                  @"data[User][fb_dob]": birthday,
                  @"data[User][fb_gender]": [user objectForKey:@"gender"],
                  @"data[User][fb_image]" : userImageURL,
                  @"data[DeviceToken][device_type]":@"ios",
                  @"data[DeviceToken][device_token]" : deviceToken,
                  @"data[DeviceToken][stage]":@"production"
                  };
    }
    
    [AppAPI facebookLogin:params block:^(NSDictionary *JSON, NSError *error) {
        if (error == nil && [JSON valueForKey:@"success"]) {
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[JSON valueForKeyPath:@"user"]];
            NSLog(@"fb login %@", [data valueForKey:@"fbid"]);
            if ([data valueForKey:@"fbid"] == [NSNull null]) {
                [data removeObjectForKey:@"fbid"];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:@"auth"];
            [defaults synchronize];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"setInterval"
             object:nil];
            
            NSLog(@"fb login %@", [data valueForKey:@"user.is_new"]);
            
            if([[JSON valueForKey:@"user.is_new"] boolValue]){
                [self performSegueWithIdentifier:@"fblogin" sender:self];
            }else{
                [(NavMenuController*)self.navigationController.parentViewController replaceView:@"mainNav"];
            }
        }
    }];
    
    
    
}
- (IBAction)login:(id)sender {
    
    NSString *emailAddress = _email.text;
    NSString *password = _password.text;
    
    
    
    if ([emailAddress isEqualToString:@""] || [password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please complete all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![self IsValidEmail:emailAddress]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Incorrect email address or password, please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // TODO:
    //NSString *deviceToken;
    NSString *deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    
    NSDictionary *loginData;
    
    if (deviceToken != nil) {
        loginData = @{@"data[User][email]" : emailAddress,
                      @"data[User][password]" : password,
                      @"data[DeviceToken][device_type]":@"ios",
                      @"data[DeviceToken][device_token]" : deviceToken,
                      @"data[DeviceToken][stage]":@"production"
                      };
    } else {
        loginData = @{@"data[User][email]" : emailAddress,
                      @"data[User][password]" : password,
                      @"data[DeviceToken][device_type]":@"ios",
                      @"data[DeviceToken][stage]":@"production"
                      };
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [AppAPI login:loginData block:^(NSDictionary *JSON, NSError *error) {
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[JSON valueForKeyPath:@"user"]];
            
            if ([data valueForKey:@"fbid"] == [NSNull null]) {
                [data removeObjectForKey:@"fbid"];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:@"auth"];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"getDataCounter"
             object:nil];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"setInterval"
             object:nil];
            
            // go to my recently asked questions page
            [(NavMenuController*)self.navigationController.parentViewController replaceView:@"mainNav"];
        }
        else {
            UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[JSON valueForKeyPath:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMsgAlert show];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - KEYBOARD VIEW ******************************************************************************
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    origin = self.view.frame.origin.y;
    
}
-(void)perpareTextFieldsInputViews{
    // find all textField
    for(id x in [self.view subviews]){
        if([x isKindOfClass:[UITextField class]]){
            UITextField *textField = (UITextField*)x;
            textField.layer.borderColor = [UIColor colorWithWhite:229.0/255.0 alpha:1.5].CGColor;
            textField.delegate = self;
            textField.inputAccessoryView = _kbToolbar;
            [textFields addObject:textField];
        }
    }
    // last text field (dob) is datepicker
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    [self animateView_Up:&textFieldRect];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSUInteger index = [textFields indexOfObject:textField];
    
    if (index != NSNotFound) {
        _kbTitle.title = textField.placeholder;
        currentIndex = index;
    }
    
    return YES;
}

- (IBAction)focusPrevField:(id)sender {
    if (currentIndex == 0)
        currentIndex = textFields.count - 1;
    else
        currentIndex--;
    
    [(UITextField*)textFields[currentIndex] becomeFirstResponder];
}
- (IBAction)focusNextField:(id)sender {
    if (currentIndex == textFields.count - 1)
        currentIndex = 0;
    else
        currentIndex++;
    
    [(UITextField*)textFields[currentIndex] becomeFirstResponder];
    
}
- (IBAction)doneEditing:(id)sender {
    [(UITextField*)textFields[currentIndex] resignFirstResponder];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateView_Down];
}
#pragma animation functions
- (void)animateView_Up: (CGRect*)rect{
    CGFloat fieldBottom = rect->origin.y+rect->size.height;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect viewFrame = self.view.frame;
    
    CGFloat animatedDistance;
    
    if (fieldBottom<(screenHeight-PORTRAIT_KEYBOARD_HEIGHT) && viewFrame.origin.y == origin) {
        animatedDistance = 0;
        return;
    }    else{
        animatedDistance = fieldBottom - (screenHeight-PORTRAIT_KEYBOARD_HEIGHT);
    }
    
    [self aniamteFields:animatedDistance down:NO];
    
}
- (void) animateView_Down{
    [self aniamteFields:origin down:YES];
}

- (void)aniamteFields:(CGFloat)distance down:(BOOL)down{
    CGRect viewFrame = self.view.frame;
    if (down) {
        viewFrame.origin.y = distance;
    }else{
        viewFrame.origin.y -= distance;
    }
    
    if (viewFrame.origin.y > origin) {
        viewFrame.origin.y = origin;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewFrame;
    }];
}
#pragma mark - END OF KEYBOARD VIEW ***********************************************************************

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"fblogin"] && fbLoginInfo != nil) {
        ((Signup*)segue.destinationViewController).fbLoginInfo = fbLoginInfo;
    }
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
@end
