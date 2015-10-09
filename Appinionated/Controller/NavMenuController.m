//
//  NavMenuController.m
//  Appinionated
//
//  Created by Tamal on 10/29/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "NavMenuController.h"
#import "Nav.h"
#import "AppAPI.h"


@interface NavMenuController () {
    Nav *mainNav;
    NSDictionary *auth;
    NSTimer *interval;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollMenuView;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;

@end

@implementation NavMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _scrollMenuView.contentSize = CGSizeMake(89, 530);
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    // add main navigation as center view
    if (auth == nil) { // not logged in
        mainNav = [self.storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    } else { // already logged in
        mainNav = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNav"];
        
        [self getCounterData];
        [self setInterval];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCounterData) name:@"getDataCounter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setInterval) name:@"setInterval" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopInterval) name:@"stopInterval" object:nil];
    }
    [self.view addSubview:mainNav.view];
    [self addChildViewController:mainNav];
    [mainNav didMoveToParentViewController:self];
}
-(void)setInterval{
    interval = [NSTimer scheduledTimerWithTimeInterval:15
                                                target:self
                                              selector:@selector(getCounterData)
                                              userInfo:nil
                                               repeats:YES];
}

-(void)stopInterval{
    [interval invalidate];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self stopInterval];
}

-(void)getCounterData{
    auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
    [AppAPI getQuestionCounter:[[auth valueForKey:@"id"]integerValue]block:^(NSDictionary *JSON, NSError *error) {
        if (error == nil && [[JSON valueForKeyPath:@"success"] boolValue]) {
            //auth = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth"];
            //NSLog(@"Count %@",[JSON valueForKeyPath:@"count"]);
            if ([[JSON valueForKey:@"count"] integerValue] == 0) {
                _counterLabel.hidden = YES;
            }else{
                _counterLabel.hidden = NO;
            }
            [_counterLabel setText:[[JSON valueForKey:@"count"] stringValue]];
        }
    }];
}

-(void)replaceView:(NSString*)identifier{
    [mainNav.view removeFromSuperview];
    [mainNav removeFromParentViewController];
    
    mainNav = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self.view addSubview:mainNav.view];
    [self addChildViewController:mainNav];
    [mainNav didMoveToParentViewController:self];
}

-(IBAction)leftMenuAction:(UIButton*)btn {
    NSString *identifier = @"";
    NSLog(@"%ld", (long)btn.tag);
    switch (btn.tag) {
        case 1:
            [mainNav popToRootViewControllerAnimated:NO];
            [mainNav toggleMenu];
            break;
        case 2:
            identifier = @"MyQuestion";
            break;
        case 3:
            identifier = @"GroupView";
            break;
        case 4:
            identifier = @"ProfileView";
            break;
        case 5:
            identifier = @"AboutView";
            break;
        case 6:
            [self logout];
            break;
        default:
            break;
    }
    
    if (![identifier isEqualToString:@""]) {
        [mainNav popToRootViewControllerAnimated:NO];
        [mainNav pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:identifier] animated:NO];
    }
}

-(void)logout{
    NSLog(@"asdasd");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"auth"];
    [defaults synchronize];
    [interval invalidate];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    // go back to Login page
    //[(NavMenuController*)self.presentingViewController.parentViewController replaceView:@"loginNav"];
    [self replaceView:@"loginNav"];
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
