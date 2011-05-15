//
//  DoubleNavigationTitleView.m
//  Paste
//
//  Created by Grant Paul on 12/18/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
//

#import "DoubleNavigationTitleView.h"


//TODO: fix landscape on iphone (not ipad);

@implementation DoubleNavigationTitleView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self addTarget:self action:@selector(touchesCompleted) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchesBegan) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchesCanceled) forControlEvents:UIControlEventTouchDragExit];
        
        selectionHighlight = [[UIView alloc] initWithFrame:[self bounds]];
        [selectionHighlight setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [selectionHighlight setBackgroundColor:[UIColor whiteColor]];
        [selectionHighlight setHidden:YES];
        [selectionHighlight setAlpha:0.3f];
        [[selectionHighlight layer] setCornerRadius:5.0f];
        [self addSubview:selectionHighlight];
        [selectionHighlight release];
        
        UIColor *labelColor, *shadowColor;
        CGSize shadowOffset;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            labelColor = [UIColor grayColor];
            shadowColor = [UIColor whiteColor];
            shadowOffset = CGSizeMake(0, 1.0f);
        } else {
            labelColor = [UIColor whiteColor];
            shadowColor = [UIColor darkGrayColor];
            shadowOffset = CGSizeMake(0, -1.0f);
        }
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [titleLabel setTextColor:labelColor];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setShadowOffset:shadowOffset];
        [titleLabel setShadowColor:shadowColor];
        [self addSubview:titleLabel];
        [titleLabel release];
        
        subtitleLabel = [[UILabel alloc] init];
        [subtitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
        [subtitleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [subtitleLabel setTextColor:labelColor];
        [subtitleLabel setTextAlignment:UITextAlignmentCenter];
        [subtitleLabel setBackgroundColor:[UIColor clearColor]];
        [subtitleLabel setShadowOffset:shadowOffset];
        [subtitleLabel setShadowColor:shadowColor];
        [self addSubview:subtitleLabel];
        [subtitleLabel release];
        
        dotLabel = [[UILabel alloc] init];
        [dotLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
        [dotLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [dotLabel setText:@" · "];
        [dotLabel setTextColor:labelColor];
        [dotLabel setTextAlignment:UITextAlignmentCenter];
        [dotLabel setBackgroundColor:[UIColor clearColor]];
        [dotLabel setShadowOffset:shadowOffset];
        [dotLabel setShadowColor:shadowColor];
        [dotLabel setHidden:YES];
        [self addSubview:dotLabel];
        [dotLabel release];
        
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat titleHeight = [[titleLabel font] leading];
    CGFloat subtitleHeight = [[subtitleLabel font] leading];
    
    if (self.bounds.size.height >= titleHeight + subtitleHeight) {
        CGFloat titleOffset = ceilf(((self.bounds.size.height / 4) * 1) - (titleHeight / 2));
        CGRect titleFrame = CGRectMake(0.0f, titleOffset, self.bounds.size.width, titleHeight);
        [titleLabel setFrame:titleFrame];
    
        CGFloat subtitleOffset = floorf(((self.bounds.size.height / 4) * 3) - (subtitleHeight / 2));
        CGRect subtitleFrame = CGRectMake(0.0f, subtitleOffset, self.bounds.size.width, subtitleHeight);
        [subtitleLabel setFrame:subtitleFrame];
        
        [dotLabel setHidden:YES];
    } else {
        CGSize titleSize = [[titleLabel text] sizeWithFont:[titleLabel font]];
        CGSize subtitleSize = [[subtitleLabel text] sizeWithFont:[subtitleLabel font]];
        CGSize dotSize = [[dotLabel text] sizeWithFont:[dotLabel font]];
        
        CGFloat titleOffset = floorf((self.bounds.size.width - (titleSize.width + subtitleSize.width + dotSize.width)) / 2);
        CGRect titleFrame = CGRectMake(titleOffset, 0.0f, titleSize.width, self.bounds.size.height);
        [titleLabel setFrame:titleFrame];
        
        CGFloat dotOffset = titleOffset + titleSize.width;
        CGRect dotFrame = CGRectMake(dotOffset, 0.0f, dotSize.width, self.bounds.size.height);
        [dotLabel setFrame:dotFrame];
        
        CGFloat subtitleOffset = dotOffset + dotSize.width;
        CGRect subtitleFrame = CGRectMake(subtitleOffset, 0.0f, subtitleSize.width, self.bounds.size.height);
        [subtitleLabel setFrame:subtitleFrame];
        
        [dotLabel setHidden:NO];
    }
}

- (void)_setSelected:(BOOL)selected {
    [selectionHighlight setHidden:!selected];
}

- (void)touchesBegan {
    [self _setSelected:YES];
}

- (void)touchesCanceled {
    [self _setSelected:NO];
}

- (void)touchesCompleted {
    [self _setSelected:NO];
    
    if ([delegate respondsToSelector:@selector(doubleNavigationViewWasTapped:)])
        [delegate doubleNavigationViewWasTapped:self];
}

- (NSString *)title {
    return [titleLabel text];
}

- (void)setTitle:(NSString *)title {
    [titleLabel setText:title];
    [self setNeedsLayout];
}

- (NSString *)subtitle {
    return [subtitleLabel text];
}

- (void)setSubtitle:(NSString *)subtitle {
    [subtitleLabel setText:subtitle];
    [self setNeedsLayout];
}

- (void)dealloc {
    [super dealloc];
}

@end
