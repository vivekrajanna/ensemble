//
//  UIView+Blur.h
//  Hoover
//
//  Created by sanjay on 2/24/14.
//
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface UIView (Blur)

-(FXBlurView *) addBlurWithBlurRadius:(CGFloat) blurRadius toFrame:(CGRect)frame;
-(FXBlurView *) addBlurWithBlurRadius:(CGFloat)blurRadius belowSubView:(UIView *) belowView toFrame:(CGRect)frame;
-(FXBlurView *) addBlurWithBlurRadius:(CGFloat)blurRadius aboveSubView:(UIView *) aboveView toFrame:(CGRect)frame;

-(void) removeBlurView:(FXBlurView *) blurView;

@end
