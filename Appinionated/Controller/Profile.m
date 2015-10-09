//
//  Profile.m
//  Appinionated
//
//  Created by Tamal on 10/27/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//
#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#import "UIImage+FixOrientation.h"
#import "UIImage+Resize.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MBProgressHUD.h"
#import "AppAPI.h"
#import "UIButton+AFNetworking.h"
#import "Profile.h"

@interface Profile (){
    NSMutableArray *textFields;
    NSUInteger currentIndex;
    CGFloat PORTRAIT_KEYBOARD_HEIGHT, origin;
    NSDictionary *auth;
    NSString *profileImagePath;
    NSString *profileImageThumbPath;
    NSString *profile_id;
}
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIToolbar *kbToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *kbTitle;
@property (weak, nonatomic) IBOutlet UIButton *addImageBtn;

@end

@implementation Profile

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    [self loadProfileData];
    
    PORTRAIT_KEYBOARD_HEIGHT = IPAD ? 318 : 270;
    textFields = [NSMutableArray array];
    [self perpareTextFieldsInputViews];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    origin = self.view.frame.origin.y;
    
    
    _password.layer.borderColor=_username.layer.borderColor=_phone.layer.borderColor=_email.layer.borderColor=[UIColor colorWithWhite:229.0/255.0 alpha:1.5].CGColor;
    _addImageBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self leftRightView:_username];
    [self leftRightView:_email];
    [self leftRightView:_phone];
    [self leftRightView:_password];
}

-(void)loadProfileData{
    profile_id = [auth valueForKey:@"id"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI showProfileInfo:[profile_id integerValue] block:^(NSDictionary *JSON, NSError *error) {
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            NSLog(@"JSON %@", [JSON valueForKeyPath:@"user"]);
            _username.text = [JSON valueForKeyPath:@"user.name"];//[auth valueForKey:@"name"];
            _email.text = [JSON valueForKeyPath:@"user.email"];//[auth valueForKey:@"email"];
            _phone.text = [JSON valueForKeyPath:@"user.mobile"];//[auth valueForKey:@"mobile"];
            if ([JSON valueForKeyPath:@"user.image"]!= [NSNull null]) {
                [_addImageBtn setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[JSON valueForKeyPath:@"user.image"]]];
            }
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[JSON valueForKeyPath:@"user"]];
            
            NSMutableDictionary *dict = [data mutableCopy];
            NSArray *keysForNullValues = [dict allKeysForObject:[NSNull null]];
            [dict removeObjectsForKeys:keysForNullValues];
            NSLog(@" dict %@",dict);
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:dict forKey:@"auth"];
            [defaults synchronize];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
}

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
    
    profileImagePath = nil;
    profileImageThumbPath = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *originalImage = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
        
        // resize image to max 1000px on one side
        //UIImage *image = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1000,1000) interpolationQuality:kCGInterpolationHigh];
        
        // resize to 420x420
        UIImage *image = [originalImage thumbnailImage:420 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        
        // generate thumb photo
        UIImage *thumb = [originalImage thumbnailImage:244 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        
        
        [_addImageBtn setImage:thumb forState:UIControlStateNormal];
        [_addImageBtn setTitle:@"" forState:UIControlStateNormal];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        profileImagePath = [self writeMedia:imageData fileName:@"profile.jpg"];
        
        NSData *thumbData = UIImageJPEGRepresentation(thumb, 1.0);
        profileImageThumbPath = [self writeMedia:thumbData fileName:@"profileThumb.jpg"];
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

- (IBAction)updateProfile:(id)sender {
    if ([_email.text isEqualToString:@""] || [_password.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please complete all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![self IsValidEmail:_email.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Incorrect email address or password, please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    
    NSMutableDictionary *profileData = [[NSMutableDictionary alloc]
                                        initWithDictionary:@{
                                                             @"data[User][id]" : profile_id,
                                                             @"data[User][name]" : _username.text,
                                                             @"data[User][email]" : _email.text,
                                                             @"data[User][password]" : _password.text,
                                                             @"data[User][mobile]" : _phone.text,
                                                             @"data[DeviceToken][device_type]":@"ios",
                                                             @"data[DeviceToken][device_token]" : deviceToken,//@"ce60e09f5fdbf16d1b8fdb70a14bcd698c0a0ba25dd267d20bdbf4446c1c0b0b",//deviceToken,
                                                             @"data[DeviceToken][stage]":@"production"
                                                             }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AppAPI updateProfile:profileData constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (profileImagePath != nil && profileImageThumbPath != nil) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:profileImagePath] name:@"data[User][imagex]" fileName:@"profile.jpg" mimeType:@"image/jpeg" error:nil];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:profileImageThumbPath] name:@"data[User][thumb]" fileName:@"profileThumb.jpg" mimeType:@"image/jpeg" error:nil];
        }
    } block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]){
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[JSON valueForKeyPath:@"user"]];
            
            NSMutableDictionary *dict = [data mutableCopy];
            NSArray *keysForNullValues = [dict allKeysForObject:[NSNull null]];
            [dict removeObjectsForKeys:keysForNullValues];
            NSLog(@" dict %@",dict);
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:dict forKey:@"auth"];
            [defaults synchronize];
        }else{
            
        }
    }];
    
}

-(void)leftRightView:(UITextField*)textField{
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
    textField.leftView = left;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 32)];
    UIImageView *editIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8.5, 12, 15)];
    editIcon.image = [UIImage imageNamed:@"edit-icon"];
    [right addSubview:editIcon];
    textField.rightView = right;
    textField.rightViewMode = UITextFieldViewModeAlways;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(edit:)];
    [right addGestureRecognizer:tapGesture];
}

-(void)edit:(UITapGestureRecognizer*) tap {
    [tap.view.superview becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
#pragma mark - KEYBOARD VIEW ******************************************************************************

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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
