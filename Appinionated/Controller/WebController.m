//
//  WebController.m
//  Appinionated
//
//  Created by Tamal on 3/19/15.
//  Copyright (c) 2015 Appinionated. All rights reserved.
//

#import "WebController.h"
#import "MBProgressHUD.h"

@interface WebController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebController

- (void)viewDidLoad {
    [super viewDidLoad];
  //  [self.navigationController setTitle:@"About"];
    
    _webView.delegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
