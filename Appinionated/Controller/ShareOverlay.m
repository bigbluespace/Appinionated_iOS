//
//  ShareOverlay.m
//  Appinionated
//
//  Created by Tamal on 12/14/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "ShareOverlay.h"
#import "UIImageView+AFNetworking.h"

@interface ShareOverlay ()

@end

@implementation ShareOverlay

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",_question_info);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shareOverlayClose:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)facebookShare:(id)sender {
    NSURL* url =[NSURL URLWithString:[_question_info valueForKey:@"image"]];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    //
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        
        [controller setInitialText:[_question_info valueForKey:@"question"]];
        //[controller addURL:url];
        
    
        [controller addImage:image];
        
        SLComposeViewControllerCompletionHandler onCompleteRequest = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled)
            {
                NSLog(@"Cancelled");
            }
            else
            {
                NSLog(@"Done");
            }
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler =onCompleteRequest;
        [self presentViewController:controller animated:YES completion:Nil];
        // NSLog(@"controller  %@",controller);
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook"
                                  message:@"You are not signed in to facebook, Please go to settings and sign in."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)twitterShare:(id)sender {
    NSURL* url =[NSURL URLWithString:[_question_info valueForKey:@"image"]];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[_question_info valueForKey:@"question"]];
        [tweetSheet addImage:image];
        SLComposeViewControllerCompletionHandler onCompleteRequest = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled)
            {
                NSLog(@"Cancelled");
            }
            else
            {
                NSLog(@"Done");
            }
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        };
        tweetSheet.completionHandler =onCompleteRequest;
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and Please go to settings and sign in."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (IBAction)messageShare:(id)sender {
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]){
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:@[]];
        [messageController setBody:[_question_info valueForKey:@"question"]];
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    NSLog(@"%u", result);
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
