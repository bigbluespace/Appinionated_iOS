//
//  About.m
//  Appinionated
//
//  Created by Tamal on 10/26/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "About.h"
#import "AppAPI.h"
#import "SelectContact.h"
#import "MBProgressHUD.h"

@interface About (){
    NSMutableArray *settings;
    NSString *pageInfo;
}
@property (weak, nonatomic) IBOutlet UIWebView *aboutWebView;

@end

@implementation About

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [self.navigationController setTitle:@"About"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _aboutWebView.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadSettings];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)loadSettings{
    NSString *url = @"http://appinionated-custom.appinstitute.co.uk/settings/about";
    NSURL *aboutContent = [NSURL URLWithString:url];
    [_aboutWebView loadRequest:[NSURLRequest requestWithURL:aboutContent]];
   /* [AppAPI settings:^(NSDictionary *JSON, NSError *error) {
        if (error == nil && [JSON valueForKeyPath:@"success"]) {
           // _aboutField.text = [JSON valueForKeyPath:@"info.about_us"];
            NSString *aboutHtmlData = [JSON valueForKeyPath:@"info.about_us"];
            //NSString *aboutHtml = [NSString stringWithFormat:@"<html><head></head><body style=\"font-family:Helvetica Neue font-size:12dp\">%@</body>", aboutHtmlData];
            //[_aboutWebView loadHTMLString:aboutHtml baseURL:nil];
            //[_aboutWebView loadRequest:[NSURL URLWithString:aboutHtmlData]];
            settings = [JSON valueForKeyPath:@"info"];
        }
    }];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recommendToFriend:(id)sender {
    pageInfo = @"aboutRecommanded";
    [self performSegueWithIdentifier:@"aboutContact" sender:self];
}

- (IBAction)rateAppinStore:(id)sender {
    //https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/
    NSString *str = @"itms-apps://itunes.apple.com/app/id969045081";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (IBAction)reportAbuse:(id)sender {
    //pageInfo = @"aboutReport";
    //[self performSegueWithIdentifier:@"aboutContact" sender:self];
    NSString *emailTitle = @"Appinionated - Report User";
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:emailTitle];
        [mailController setToRecipients:@[@"support@appinionated.com"]];
        [mailController setMessageBody:@"The following user has been reported as abusing the App:\n\n{email address}\n\nThanks,\nThe Appinionated Team." isHTML:NO];
        
        // Present mail view controller on screen
        [self presentViewController:mailController animated:YES completion:nil];
    }
}

- (IBAction)emailUs:(id)sender {
    NSString *emailTitle = @"Appinionated";
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:emailTitle];
        [mailController setToRecipients:@[@"support@appinionated.com"]];
        [mailController setMessageBody:@"" isHTML:NO];
        
        // Present mail view controller on screen
        [self presentViewController:mailController animated:YES completion:nil];
    }
}


#pragma mark - Navigation

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"aboutContact"]) {
        ((SelectContact*)segue.destinationViewController).pageInfo = pageInfo;
    }

}


@end
