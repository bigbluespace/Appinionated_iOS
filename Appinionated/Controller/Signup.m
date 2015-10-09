//
//  Signup.m
//  Appinionated
//
//  Created by Tamal on 10/26/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#import "Signup.h"
#import "AppAPI.h"
#import "MBProgressHUD.h"
#import "WebController.h"
#import "NavMenuController.h"

@interface Signup (){
    NSDate *selectedDob;
    NSString *dob_date, *fbid; // in mysql format
    
    NSMutableArray *textFields;
    NSUInteger currentIndex;
    CGFloat PORTRAIT_KEYBOARD_HEIGHT, origin;
    
    NSString *url;
}
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumber;

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *dob;
@property (weak, nonatomic) IBOutlet UIButton *female;
@property (weak, nonatomic) IBOutlet UIButton *male;

@property (strong, nonatomic) IBOutlet UIToolbar *kbToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *kbTitle;
@property (strong, nonatomic) IBOutlet UIDatePicker *kbDatePicker;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *termCheck;
@property (weak, nonatomic) IBOutlet UILabel *termService;
@property (weak, nonatomic) IBOutlet UILabel *privacyService;


@end

@implementation Signup

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    fbid = @"";
    
    PORTRAIT_KEYBOARD_HEIGHT = IPAD ? 318 : 270;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    _male.selected = YES;
    if(_fbLoginInfo != nil){
        fbid = [_fbLoginInfo valueForKey:@"id"];
        NSLog(@"%@", fbid);
        _userName.text = [_fbLoginInfo valueForKey:@"first_name"];
        _email.text = [_fbLoginInfo valueForKey:@"email"];
        
        NSString *birthday =[_fbLoginInfo valueForKey:@"birthday"];
        if(birthday != nil){
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            
            NSDate *dob = [dateFormat dateFromString:birthday];
            
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            dob_date = [dateFormat stringFromDate:dob];
            
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
            _dob.text = [dateFormat stringFromDate:dob];
        }
        if([[_fbLoginInfo valueForKey:@"gender"] isEqualToString:@"male"]){
            _male.selected = YES;
        }
        if([[_fbLoginInfo valueForKey:@"gender"] isEqualToString:@"female"]){
            _female.selected = YES;
        }
    }else{
        dob_date = @"1970-01-01";
    }
    
    
    
    textFields = [NSMutableArray array];
    
    [self perpareTextFieldsInputViews];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)onTermCheck:(UIButton*)checkBox {
    
        checkBox.selected = !checkBox.selected;
    
}


- (IBAction)signup:(id)sender {
    
    NSString *emailAddress = _email.text;
    NSString *password = _password.text;
    NSString *mobileNumber = _mobileNumber.text;
    NSString *userName = _userName.text;
    NSString *gender = @"male";
    if (_male.selected) {
        gender = @"male";
    }
    if (_female.selected) {
        gender = @"female";
    }
    
    if ([emailAddress isEqualToString:@""] || ![self IsValidEmail:emailAddress] || [password isEqualToString:@""] || [mobileNumber isEqualToString:@""] || [userName isEqualToString:@"" ]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please complete all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!_termCheck.selected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please accept the terms of use." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // TODO:
    //NSString *deviceToken;
    NSString *deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    
    NSDictionary *signupData;
    
    if (deviceToken != nil) {
        signupData = @{@"data[User][email]" : emailAddress,
                       @"data[User][fbid]" : fbid,
                       @"data[User][password]" : password,
                       @"data[User][name]" : userName,
                       @"data[User][mobile]" : mobileNumber,
                       @"data[User][dob]" : dob_date,
                       @"data[User][gender]" : gender,
                       @"data[DeviceToken][device_type]":@"ios",
                       @"data[DeviceToken][device_token]" : deviceToken,
                       @"data[DeviceToken][stage]":@"production"
                       };
    } else {
        signupData = @{@"data[User][email]" : emailAddress,
                       @"data[User][fbid]" : fbid,
                       @"data[User][password]" : password,
                       @"data[User][name]" : userName,
                       @"data[User][mobile]" : mobileNumber,
                       @"data[User][dob]" : dob_date,
                       @"data[User][gender]" : gender,
                       @"data[DeviceToken][device_type]":@"ios",
                       @"data[DeviceToken][stage]":@"production"
                       };
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [AppAPI signup:signupData block:^(NSDictionary *JSON, NSError *error) {
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            NSDictionary *data = [JSON valueForKeyPath:@"user"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:@"auth"];
            [defaults synchronize];
            
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
    ((UITextField*)[textFields lastObject]).inputView = _kbDatePicker;
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
- (IBAction)updateDob:(UIDatePicker*)datePicker {
    selectedDob = datePicker.date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"YYYY-MM-dd"; // mysql date format
    dob_date = [df stringFromDate:selectedDob];
    df.dateFormat = @"dd/MM/YYYY"; // UK date format to display
    _dob.text = [df stringFromDate:selectedDob];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectGender:(UIButton*)btn {
    if (btn == _female) {
        _female.selected = YES;
        _male.selected = NO;
    } else {
        _female.selected = NO;
        _male.selected = YES;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"privacy"] || [segue.identifier isEqualToString:@"terms"]){
        url = [NSString stringWithFormat:@"http://appinionated-custom.appinstitute.co.uk/settings/%@",segue.identifier];
        ((WebController*)segue.destinationViewController).url = [NSURL URLWithString:url];

    }
    
}


@end
