//
//  DoubleNavigationTitleView.h
//  Paste
//
//  Created by Grant Paul on 12/18/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol DoubleNavigationDelegate;

@interface DoubleNavigationTitleView : UIControl {
    UILabel *titleLabel;
    UILabel *subtitleLabel;
    UILabel *dotLabel;
    UIView *selectionHighlight;
    id<DoubleNavigationDelegate> delegate;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) id<DoubleNavigationDelegate> delegate;

@end

@protocol DoubleNavigationDelegate<NSObject>
@optional
- (void)doubleNavigationViewWasTapped:(id)dnv;
@end

