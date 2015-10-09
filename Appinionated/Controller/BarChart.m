//
//  PieChart.m
//  Appinionated
//
//  Created by Tamal on 12/7/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
#import "BarChart.h"

@implementation BarChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setOpaque:NO];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSInteger percent = 0;
    NSInteger answer_count = _answers.count;
    NSInteger bar_space = 250/answer_count;
    NSArray *ABCD = @[@"A", @"B", @"C", @"D"];
    
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:[UIColor colorWithRed:241.0/255.0 green:172.0/255.0 blue:27.0/255.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithRed:97.0/255.0 green:15.0/255.0 blue:151.0/255.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithRed:142.0/255.0 green:12.0/255.0 blue:71.0/255.0 alpha:1.0]];
    
    if (answer_count == 0) {
        answer_count = 4;
    }
    
    for (int i = 0; i<answer_count; i++) {
        if([_answers[i] valueForKey:@"percentage"]&&[_answers[i] valueForKey:@"percentage"]!=[NSNull null])
            percent = [[_answers[i] valueForKey:@"percentage"] integerValue];
        else
            percent = 0;
       // NSLog(@"percent %lu",percent);
        CGFloat bar_height = (percent/100.0)*190.0;
        CGFloat y = 210.0 - bar_height;
        CGFloat x = (bar_space*i)+(bar_space/2)-27;
        if (bar_height == 0) {
            bar_height = 1;
            y = 209;
        }
      //  NSLog(@"%f %f",x, y);
        
        [colors[i] setFill];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, 54, bar_height) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        
    
        [bezierPath fill];
        [ABCD[i] drawAtPoint:CGPointMake((x+22.0),(y-18.0))
              withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:12.0],
                               NSForegroundColorAttributeName:colors[i]
                               }];
    }
}

@end
