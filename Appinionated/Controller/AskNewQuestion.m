//
//  AskNewQuestion.m
//  Appinionated
//
//  Created by Tamal on 10/27/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//
#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#import "AskNewQuestion.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Resize.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MBProgressHUD.h"
#import "AppAPI.h"
#import "SelectContact.h"
#import "Group.h"
#import "UIButton+AFNetworking.h"

@interface AskNewQuestion (){
    NSMutableArray *textFields;
    NSUInteger currentIndex;
    CGFloat PORTRAIT_KEYBOARD_HEIGHT, origin;
    NSDictionary *auth;
    NSString *questionImagePath;
    NSString *questionImageThumbPath;
    NSString *question_id;
    NSDictionary *questionInfo;
    NSString *pageInfo;
    NSMutableDictionary *questionDataFile;
}
@property (weak, nonatomic) IBOutlet UITextView *enterQuestion;
@property (weak, nonatomic) IBOutlet UITextField *enterAnsOption1;
@property (weak, nonatomic) IBOutlet UITextField *enterAnsOption2;
@property (weak, nonatomic) IBOutlet UITextField *enterAnsOption3;
@property (weak, nonatomic) IBOutlet UITextField *enterAnsOption4;
@property (strong, nonatomic) IBOutlet UIToolbar *kbToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *kbTitle;
@property (weak, nonatomic) IBOutlet UIButton *addAnsOption;
@property (weak, nonatomic) IBOutlet UIButton *addImageBtn;

@end

@implementation AskNewQuestion

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    _enterAnsOption1.layer.borderColor=_enterAnsOption2.layer.borderColor=_enterQuestion.layer.borderColor=[UIColor colorWithWhite:229.0/255.0 alpha:1.5].CGColor;
    _enterQuestion.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    PORTRAIT_KEYBOARD_HEIGHT = IPAD ? 318 : 270;
    textFields = [NSMutableArray array];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearForm) name:@"clearForm" object:nil];
    [self perpareTextFieldsInputViews];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_questionData != nil) {
        [self loadQuestionData];
    }
     origin = self.view.frame.origin.y;
}

-(void)clearForm{
    _enterQuestion.text = @"Enter Question";
    _enterAnsOption1.text = @"";
    _enterAnsOption2.text = @"";
    _enterAnsOption3.text = @"";
    _enterAnsOption4.text = @"";
    [_addImageBtn setImage:[UIImage imageNamed:@"add-image"] forState:UIControlStateNormal];
}


-(void) loadQuestionData{
    questionImagePath = nil;
    questionImageThumbPath = nil;
    
    _enterQuestion.text = @"";
    _enterQuestion.text = [_questionData valueForKeyPath:@"question.question"];
    
    
    NSString *url = [_questionData valueForKeyPath:@"question.image"];
    NSURL *imageUrl = [NSURL URLWithString:url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *originalImg = [UIImage imageWithData:imageData];
    [self imageResizer:originalImg];
    
    NSArray *answers = [_questionData valueForKey:@"answers"];
    _enterAnsOption1.text = [answers[0] valueForKeyPath:@"answer"];
    _enterAnsOption2.text = [answers[1] valueForKeyPath:@"answer"];
     if (answers.count > 2) {
         if (answers.count >= 3) {
             _enterAnsOption3.text = [answers[2] valueForKeyPath:@"answer"];
             _enterAnsOption3.hidden = NO;
         }
         if (answers.count == 4) {
             _enterAnsOption4.text = [answers[3] valueForKeyPath:@"answer"];
             _enterAnsOption4.hidden = NO;
             _addAnsOption.hidden = YES;
         }else{
             _addAnsOption.hidden = NO;
         }
     }else{
         _enterAnsOption3.hidden = YES;
         _enterAnsOption4.hidden = YES;
     }
    
}

- (IBAction)addNewAns:(UIButton*)btn {
    if (_enterAnsOption3.hidden) {
        _enterAnsOption3.hidden = NO;
        [textFields addObject:_enterAnsOption3];
    } else if (_enterAnsOption4.hidden){
        _enterAnsOption4.hidden = NO;
        [textFields addObject:_enterAnsOption4];
        btn.hidden = YES;
    }
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    NSLog(@"%@", textView.text);
    if ([textView.text isEqualToString:@"Enter Question"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter Question";
        textView.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    }
    return YES;
}



// send to contact / group
// first save the question in db via api post request
-(IBAction)saveQuestion:(UIButton*)btn{
    NSString *question = _enterQuestion.text;
    questionDataFile = [[NSMutableDictionary alloc]
                                         initWithDictionary:@{
                                                              @"data[Question][question]" : question,
                                                              @"data[Question][user_id]" : [auth valueForKey:@"id"],
                                                              }];
    NSUInteger qCounter = 0;
    for (UITextField *a in textFields) {
        if (a.text.length) {
            NSString *key = [NSString stringWithFormat:@"data[Answer][%lu][answer]", (unsigned long)qCounter];
            [questionDataFile setValue:a.text forKey:key];
            qCounter++;
        }
    }
    
    if ([question isEqualToString:@""] || qCounter < 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please complete all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }else{
        
        if (btn.tag == 1) { //
            pageInfo = @"questionContact";
            [self performSegueWithIdentifier:@"inviteContacts" sender:self];
        } else if(btn.tag == 2) {
            [self performSegueWithIdentifier:@"inviteGroup" sender:self];
        }
    }
    
    
   /* [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [AppAPI askQuestion:questionData constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (questionImagePath != nil && questionImageThumbPath != nil) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:questionImagePath] name:@"data[Question][imagex]" fileName:@"question.jpg" mimeType:@"image/jpeg" error:nil];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:questionImageThumbPath] name:@"data[Question][thumb]" fileName:@"questionThumb.jpg" mimeType:@"image/jpeg" error:nil];
        }
    } block:^(NSDictionary *JSON, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            // next page: select contacts or group
            question_id = [JSON valueForKeyPath:@"question.questin_id"];
            questionInfo = [JSON valueForKeyPath:@"question"];
            BOOL firstTime = [[JSON valueForKeyPath:@"question.first_time"] boolValue];
            
            if (firstTime) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"If a contact does not have the Appinionated App a text message is sent to this person according to your call plan" delegate:self cancelButtonTitle:@"No, cancel" otherButtonTitles:@"Yes, go for it",nil];
                [alert show];
            }
            
            if (btn.tag == 1) { //
                pageInfo = @"questionContact";
                [self performSegueWithIdentifier:@"inviteContacts" sender:self];
            } else if(btn.tag == 2) {
                [self performSegueWithIdentifier:@"inviteGroup" sender:self];
            }
        } else {
            UIAlertView *errorMsgAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[JSON valueForKeyPath:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorMsgAlert show];
        }
    }];*/
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    // the user clicked OK
//    if (buttonIndex == 1) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sms_email_permission"];
//    }else{
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sms_email_permission"];
//    }
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//}

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

-(void)imageResizer:(UIImage*)originalImage{
    UIImage *image = [originalImage thumbnailImage:420 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    
    // generate thumb photo
    UIImage *thumb = [originalImage thumbnailImage:244 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    
    
    [_addImageBtn setImage:thumb forState:UIControlStateNormal];
    [_addImageBtn setTitle:@"" forState:UIControlStateNormal];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    questionImagePath = [self writeMedia:imageData fileName:@"question.jpg"];
    
    NSData *thumbData = UIImageJPEGRepresentation(thumb, 1.0);
    questionImageThumbPath = [self writeMedia:thumbData fileName:@"questionThumb.jpg"];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    // Extract image from the picker / camera
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    questionImagePath = nil;
    questionImageThumbPath = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *originalImage = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
        [self imageResizer:originalImage];
        // resize image to max 1000px on one side
        //UIImage *image = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1000,1000) interpolationQuality:kCGInterpolationHigh];

        // resize to 420x420
        
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
            if (!textField.hidden) {
                [textFields addObject:textField];
            }
        }
    }
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



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"inviteContacts"]) {//inviteGroup
         //((SelectContact*)segue.destinationViewController).question_id = question_id;
         //((SelectContact*)segue.destinationViewController).question_info = questionInfo;
         ((SelectContact*)segue.destinationViewController).pageInfo = pageInfo;
         
         ((SelectContact*)segue.destinationViewController).questionImage = questionImagePath;
         ((SelectContact*)segue.destinationViewController).questionImageThumb = questionImageThumbPath;
         ((SelectContact*)segue.destinationViewController).questionData = questionDataFile;
     }
     if ([segue.identifier isEqualToString:@"inviteGroup"]) {//inviteGroup
//         ((Group*)segue.destinationViewController).question_id = question_id;
//         ((Group*)segue.destinationViewController).question_info = questionInfo;
         ((Group*)segue.destinationViewController).invite_type = @"Invite Group";
         
         ((Group*)segue.destinationViewController).questionImage = questionImagePath;
         ((Group*)segue.destinationViewController).questionImageThumb = questionImageThumbPath;
         ((Group*)segue.destinationViewController).questionData = questionDataFile;
     }
     
 }
 

@end
