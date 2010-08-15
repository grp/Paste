//
//  PasteViewController.m
//  Paste
//
//  Created by Grant Paul on 7/6/10.
//  Copyright 2010 Xuzz Productions. All rights reserved.
//

#import "PasteViewController.h"
#import "Pastie.h"

@interface PasteViewController () <PastieDelegate>
@end

@implementation PasteViewController

@synthesize textView;
@synthesize navigationBar;
@synthesize submitItem;
@synthesize clearItem;
@synthesize loading;
@synthesize pastie;

#pragma mark -
#pragma mark View Controller Lifetime

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"Paste"];
	[self.navigationItem setRightBarButtonItem:submitItem];
	[self.navigationItem setLeftBarButtonItem:clearItem];
	 
	pastie = [[Pastie alloc] init];
	[pastie setDelegate:self];
	
	[clearItem setTarget:self];
	[submitItem setTarget:self];
	[clearItem setAction:@selector(clearPressed)];
	[submitItem setAction:@selector(submitPressed)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	[textView setText:[[UIPasteboard generalPasteboard] string]];
	[textView setFont:[UIFont fontWithName:@"Courier" size:13.0f]];
	[textView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[textView release];
	[navigationBar release];
	[submitItem release];
	[clearItem release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Loading

- (void)setLoadingModeEnabled:(BOOL)enabled {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:enabled];
	
	if (enabled) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		/* Display loading view */
	} else {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		/* hide loading view */
	}
}

#pragma mark -
#pragma mark Delegate

- (void)clearPressed {
	[textView setText:@""];
}

- (void)submitPressed {
	[self beginSubmission];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	// Retry paste
	if (buttonIndex == 1)
		[self beginSubmission];
}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardStateChanged:(BOOL)keyboardShowing withNotification:(NSNotification *)notification {
	CGRect keyboardBounds;
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardBoundsValue getValue:&keyboardBounds];
	
	CGRect frame = [textView frame];
	if (keyboardShowing)	frame.size.height -= keyboardBounds.size.height;
	else					frame.size.height += keyboardBounds.size.height;
	[textView setFrame:frame];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	[self keyboardStateChanged:YES withNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	[self keyboardStateChanged:NO withNotification:notification];
}

#pragma mark -
#pragma mark Submission

- (void)beginSubmission {
	[self setLoadingModeEnabled:YES];
	
	[pastie beginSubmissionWithText:[textView text]];
}

- (void)submissionCompletedWithURL:(NSURL *)url {
	[self setLoadingModeEnabled:NO];
	
	[[UIPasteboard generalPasteboard] setString:[url absoluteString]];
	[[UIPasteboard generalPasteboard] setURL:url];
	
	UIAlertView *alert = [[[UIAlertView alloc] 
						   initWithTitle:@"Paste Complete" 
						   message:@"The URL has been copied to your clipboard." 
						   delegate:nil
						   cancelButtonTitle:@"Continue" 
						   otherButtonTitles:nil
						   ] autorelease];
	
	[alert show];
}

- (void)submissionFailedWithError:(NSError *)error {
	[self setLoadingModeEnabled:NO];
	
	UIAlertView *alert = [[[UIAlertView alloc] 
						   initWithTitle:@"Error" 
						   message:@"Unable to submit your paste." 
						   delegate:self
						   cancelButtonTitle:@"Cancel" 
						   otherButtonTitles:@"Retry", nil
						   ] autorelease];
	
	[alert show];
}

@end
