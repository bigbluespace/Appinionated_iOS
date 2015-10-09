//
//  Datepicker.m
//  Appinionated
//
//  Created by Tamal on 10/28/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "Datepicker.h"
#import "Signup.h"

@interface Datepicker ()
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePicker;

@end

@implementation Datepicker

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_selectedDate != nil) {
        _DatePicker.date = _selectedDate;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)done:(id)sender {
    [(Signup*)[(UINavigationController*)self.presentingViewController topViewController] setDob:_DatePicker.date];
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
