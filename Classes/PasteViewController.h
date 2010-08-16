//
//  PasteViewController.h
//  Paste
//
//  Created by Grant Paul on 7/6/10.
//  Copyright 2010 Xuzz Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Pastie;

@interface PasteViewController : UIViewController {
	UITextView *textView;
	UINavigationBar *navigationBar;
	UIBarButtonItem *clearItem;
	UIBarButtonItem *submitItem;
	BOOL loading;
	Pastie *pastie;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *clearItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *submitItem;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, retain) Pastie *pastie;

@property (nonatomic, copy) NSString *currentText;

- (void)beginSubmission;

@end
