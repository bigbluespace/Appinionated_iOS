//
//  SwipeCell.h
//  Appinionated
//
//  Created by Tamal on 12/2/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import <UIKit/UIKit.h>

UITableViewCell *previousCell;
@interface SwipeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property BOOL canSwipe;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;

@end
