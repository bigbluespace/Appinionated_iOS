//
//  PieChart.m
//  Appinionated
//
//  Created by Tamal on 12/7/14.
//  Copyright (c) 2014 Appinionated. All rights reserved.
//
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
#import "PieChart.h"

@implementation PieChart

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
    
    //CGFloat angle = 180;
    CGFloat r = 105.0;
    NSInteger percent = 0;
  
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    CGContextMoveToPoint(context, r, r);
    CGContextAddArc(context,
                    r,
                    r,
                    r,
                    DEGREES_TO_RADIANS(0),
                    DEGREES_TO_RADIANS(360),
                    0);
    CGContextSetFillColorWithColor(context,[UIColor colorWithWhite:0.99 alpha:1.0].CGColor);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    NSInteger total_percent = 0;
    int j = 1;
    NSMutableArray *angles = [NSMutableArray array];
    for (NSDictionary *answer in _answers) {
        if ([answer valueForKey:@"percentage"] && [answer valueForKey:@"percentage"] != [NSNull null]) {
            percent = [[answer valueForKey:@"percentage"] integerValue];
            if (j == _answers.count && total_percent > 0) {
                percent = 100 - total_percent;
            }
        }else{
            percent = 0;
        }
        
        //NSLog(@"Percent: %lu",percent);
        total_percent += percent;
        CGFloat angle = (percent/100.0)*360.0;
        [angles addObject:@(angle)];
        j++;
    }
    NSLog(@"%ld", (long)total_percent);
    if (total_percent == 0) {
        return;
    }
    
    CGFloat startAngle = 180.0;
    NSArray *ABCD = @[@"A", @"B", @"C", @"D"];
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:[UIColor colorWithRed:241.0/255.0 green:172.0/255.0 blue:27.0/255.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithRed:97.0/255.0 green:15.0/255.0 blue:151.0/255.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithRed:1.0/255.0 green:105.0/255.0 blue:120.0/255.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithRed:142.0/255.0 green:12.0/255.0 blue:71.0/255.0 alpha:1.0]];
    
    int i = 0;
    
    for (NSString *angle in angles) {
        CGFloat theta = [angle floatValue];
       // NSLog(@"Theta %@",angle);
        CGContextMoveToPoint(context, r, r);
        CGContextAddArc(context,
                        r,
                        r,
                        r,
                        DEGREES_TO_RADIANS(startAngle),
                        DEGREES_TO_RADIANS((startAngle+theta)),
                        0);
        CGContextSetFillColorWithColor(context,[(UIColor*)colors[i] CGColor]);
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
        
        CGFloat ea = startAngle+(theta/2);
        CGFloat t = 0;
        if (ea <= 360) {
            t = 360-ea;
        }else{
            t = 720-ea;
        }
        
        CGFloat x = r + (r/1.5)*cos(DEGREES_TO_RADIANS(t));
        CGFloat y = 2*r-(r + (r/1.5)*sin(DEGREES_TO_RADIANS(t)));
        
        x = x - 5;
        y = y - 9;
        
        //NSLog(@"x= %f, y= %f", x,y);
        
        
        if ([[_answers[i] valueForKey:@"percentage"] integerValue] > 0) {
            [ABCD[i] drawAtPoint:CGPointMake(x,y)
                  withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:12.0],
                                   NSForegroundColorAttributeName:[UIColor whiteColor]
                                   }];
        }
        startAngle += theta;
        i++;
    }
    
}

@end
