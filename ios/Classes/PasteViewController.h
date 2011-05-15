//
//  PasteViewController.h
//  Paste
//
//  Created by Grant Paul on 7/6/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Pastie;
@class DoubleNavigationTitleView;

@interface PasteViewController : UIViewController {
	UITextView *textView;
    DoubleNavigationTitleView *titleItem;
    UIPopoverController *popover; // ugh, bad API design
	UIBarButtonItem *clearItem;
	UIBarButtonItem *submitItem;
    NSString *targetLanguage;
    BOOL makePrivate;
	BOOL loading;
	Pastie *pastie;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) DoubleNavigationTitleView *titleItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *clearItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *submitItem;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, retain) Pastie *pastie;

@property (nonatomic, copy) NSString *currentText;
@property (nonatomic, copy) NSString *targetLanguage;
@property (nonatomic, assign) BOOL makePrivate;

- (void)beginSubmission;

@end
