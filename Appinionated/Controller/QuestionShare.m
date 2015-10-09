//
//  QuestionShare.m
//  Appinionated
//
//  Created by Tamal on 10/29/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "QuestionShare.h"
#import "ShareOverlay.h"
#import "NavMenuController.h"

@interface QuestionShare (){
    
}

@property (weak, nonatomic) IBOutlet UILabel *receiversTitle;
@end

@implementation QuestionShare

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _receiversTitle.text = [NSString stringWithFormat:@"Your question has been sent to %@", _name];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender {
}
- (IBAction)askAnother:(id)sender {
    NSArray *vcs = [self.navigationController viewControllers];
    NSInteger target = vcs.count - 3;
    [self.navigationController popToViewController:vcs[target] animated:YES];
}
- (IBAction)goToMyQ:(id)sender {
    UIButton *dummyBtn = [[UIButton alloc] init];
    dummyBtn.tag = 2;
    [(NavMenuController*)self.navigationController.parentViewController leftMenuAction:dummyBtn];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"recommendSegue"]) {
        ((ShareOverlay*)segue.destinationViewController).modalPresentationStyle = UIModalPresentationOverCurrentContext;
        ((ShareOverlay*)segue.destinationViewController).question_info = _question_info;
    }
}


@end
