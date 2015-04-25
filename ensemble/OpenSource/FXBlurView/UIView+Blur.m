//
//  UIView+Blur.m
//  Hoover
//
//  Created by sanjay on 2/24/14.
//
//

#import "UIView+Blur.h"


@implementation UIView (Blur)


-(FXBlurView *) addBlurWithBlurRadius:(CGFloat) blurRadius toFrame:(CGRect)frame
{
    FXBlurView * blurView = [[FXBlurView alloc]initWithFrame:frame];
    blurView.backgroundColor = [UIColor clearColor];
    blurView.dynamic = NO;
    blurView.contentMode = UIViewContentModeCenter;
    blurView.blurEnabled = YES;
    blurView.tintColor = [UIColor clearColor];
    blurView.blurRadius = blurRadius;
    
    [self addSubview:blurView];
    return blurView;
}

-(FXBlurView *) addBlurWithBlurRadius:(CGFloat)blurRadius belowSubView:(UIView *) belowView toFrame:(CGRect)frame
{
    FXBlurView * blurView = [[FXBlurView alloc]initWithFrame:frame];
    blurView.backgroundColor = [UIColor clearColor];
    blurView.dynamic = NO;
    blurView.contentMode = UIViewContentModeCenter;
    blurView.blurEnabled = YES;
    blurView.blurRadius = blurRadius;
    blurView.tintColor = [UIColor clearColor];
    [self insertSubview:blurView belowSubview:belowView];
    return blurView;
}
-(FXBlurView *) addBlurWithBlurRadius:(CGFloat)blurRadius aboveSubView:(UIView *) aboveView toFrame:(CGRect)frame
{
    FXBlurView * blurView = [[FXBlurView alloc]initWithFrame:frame];
    blurView.backgroundColor = [UIColor clearColor];
    blurView.dynamic = NO;
    blurView.contentMode = UIViewContentModeCenter;
    blurView.tintColor = [UIColor clearColor];
    blurView.blurEnabled = YES;
    blurView.blurRadius = blurRadius;
    
    [self insertSubview:blurView aboveSubview:aboveView];
    return blurView;
}

-(void) removeBlurView:(FXBlurView *) blurView
{
    if (blurView == nil)
    {
        return;
    }
    [blurView removeFromSuperview];
}
@end
