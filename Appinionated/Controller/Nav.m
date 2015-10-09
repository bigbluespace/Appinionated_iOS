//
//  Nav.m
//  Appinionated
//
//  Created by Tamal on 10/29/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "Nav.h"

@interface Nav ()

@end

@implementation Nav

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set bar tint color
    self.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height - 1, self.navigationBar.frame.size.width, 1)];
    bar.backgroundColor = [UIColor colorWithRed:142.0/255.0 green:12.0/255.0 blue:71.0/255.0 alpha:1.0];
    [self.navigationBar addSubview:bar];
    
    // make nav bar non-translucent
    self.navigationBar.translucent = NO;
    
    // prepare root view controller
    NSString *restorationId = self.restorationIdentifier; // story board id
    if ([restorationId isEqualToString:@"mainNav"]) {
        [self prepareViewController:self.viewControllers[0] back:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareViewController:(UIViewController*)viewController back:(BOOL)back{
    // get the navigation item
    UINavigationItem *navItem = viewController.navigationItem;
    // hide navigation bar back button
    [navItem setHidesBackButton:YES];
    
    // add menu button
    if(navItem.leftBarButtonItem == nil){
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [menu setFrame:CGRectMake(0, 0, 16, 18)];
    [menu setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    }
    // page title control
    NSString *title = navItem.title;
    NSLog(@"page title %@", title );
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:12.0/255.0 blue:71.0/255.0 alpha:1.0];
    titleLabel.font = [UIFont fontWithName:@"BeforeBreakfast" size:17];
    titleLabel.numberOfLines = 1;
    titleLabel.text = title;
    [titleLabel sizeToFit];
    CGRect titleFrame = titleLabel.frame;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, titleFrame.size.width + 40, 25)];
    UIImageView *titleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about-icon"]];
    titleIcon.frame = CGRectMake(0, 0, 28, 25);
    titleFrame.origin.x = 40;
    titleFrame.origin.y = 3;
    titleLabel.frame = titleFrame;
    [titleView addSubview:titleIcon];
    [titleView addSubview:titleLabel];
    navItem.titleView = titleView;
    
    if (back && navItem.rightBarButtonItem == nil) {
        // add back button
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0, 0, 10, 15)];
        [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    }
}
-(void)back{
    // special case
    if ( [NSStringFromClass(self.topViewController.class) isEqualToString:@"QuestionShare"] ) {
        NSArray *vcs = self.viewControllers;
        [self popToViewController:vcs[vcs.count - 4] animated:YES];
    } else {
        [self popViewControllerAnimated:YES];
    }
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // reset navigation bar position
    CGRect navFrame = self.view.frame;
    if (navFrame.origin.x > 0) {
        [self toggleMenu];
    }
    
    [self prepareViewController:viewController back:YES];
    
    // call super method
    [super pushViewController:viewController animated:animated];
}

-(void)toggleMenu {
    CGRect navFrame = self.view.frame;
    
    if (navFrame.origin.x == 0) {
        navFrame.origin.x = 90; // ************* LEFT MENU OFFSET ***********
    } else {
        navFrame.origin.x = 0;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = navFrame;
    } completion:^(BOOL finished) {
        
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
