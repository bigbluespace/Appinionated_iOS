//
//  SwipeCell.m
//  Appinionated
//
//  Created by Tamal on 12/2/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//

#import "SwipeCell.h"

@implementation SwipeCell

- (void)prepareForReuse {
    [super prepareForReuse];
    // reset all left positions and contents
    CGRect rightViewFrame = _rightView.frame;
    rightViewFrame.origin.x = CGRectGetWidth(self.frame);
    _rightView.frame = rightViewFrame;
}

- (void)awakeFromNib {
    
    self.editBtn.layer.borderColor = self.deleteBtn.layer.borderColor =[UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0].CGColor;
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:leftSwipeGestureRecognizer];
    [self addGestureRecognizer:rightSwipeGestureRecognizer];
    
}



-(void)leftSwipe:(UISwipeGestureRecognizer*)swipeLeft {
    NSLog(@" swipe left");
    NSLog(@"Can Swipe %d", _canSwipe);
    CGRect rightViewFrame = _rightView.frame;
    
    if (previousCell != nil && previousCell != (id)[NSNull null] && _canSwipe) {
        UIView *linkView = (UIView *)[previousCell viewWithTag:100 ];
        CGRect linkFrame = linkView.frame;
        
        linkFrame.origin.x = CGRectGetWidth(self.frame); // 58 = right buttons width
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             linkView.frame = linkFrame;
                         }
                         completion:^(BOOL finished){
                             //NSLog(@"Done!");
                         }];
    }
    
    if (rightViewFrame.origin.x == CGRectGetWidth(self.frame) && _canSwipe) { // currently in hidden state. move left to show
        rightViewFrame.origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(rightViewFrame);
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _rightView.frame = rightViewFrame;
                         }
                         completion:^(BOOL finished){
                             previousCell = self;
                         }];
    }
}

-(void)rightSwipe:(UISwipeGestureRecognizer*)swipeRight {
    NSLog(@" swipe right");
    CGRect rightViewFrame = _rightView.frame;
    if (rightViewFrame.origin.x == CGRectGetWidth(self.frame) - CGRectGetWidth(rightViewFrame) && _canSwipe ) { // currently in visible state. move right to hide
        rightViewFrame.origin.x = CGRectGetWidth(self.frame);
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _rightView.frame = rightViewFrame;
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
