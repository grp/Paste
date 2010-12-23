//
//  PasteViewController.m
//  Paste
//
//  Created by Grant Paul on 7/6/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
//

#import "PasteViewController.h"
#import "DoubleNavigationTitleView.h"
#import "LanguageSelectViewController.h"
#import "Pastie.h"

@interface PasteViewController () <DoubleNavigationDelegate, PastieDelegate, LanguageSelectDelegate>
@end

@implementation PasteViewController

@synthesize textView;
@synthesize titleItem;
@synthesize submitItem;
@synthesize clearItem;
@synthesize loading;
@synthesize pastie;
@synthesize targetLanguage;
@synthesize makePrivate;

#pragma mark -
#pragma mark View Controller Lifetime

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], @"private",
            @"Plain Text", @"language",
    nil]];
    [self setMakePrivate:[defaults boolForKey:@"private"]];
    [self setTargetLanguage:[defaults stringForKey:@"language"]];
    
    pastie = [[Pastie alloc] init];
	[pastie setDelegate:self];
	
	[self setTitle:@"Paste"];
    
    titleItem = [[DoubleNavigationTitleView alloc] initWithFrame:CGRectMake(0, 3.0f, 240.0f, 38.0f)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [titleItem setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    else [titleItem setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [titleItem setTitle:@"Paste to Pastie"];
    [titleItem setSubtitle:[self targetLanguage]];
    [titleItem setDelegate:self];
    [self.navigationItem setTitleView:titleItem];
    [titleItem release];
    
	[self.navigationItem setRightBarButtonItem:submitItem];
	[self.navigationItem setLeftBarButtonItem:clearItem];

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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popover dismissPopoverAnimated:NO];
        [popover presentPopoverFromRect:[self.navigationController.navigationBar frame] inView:[self.navigationController view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[textView release];
	[submitItem release];
	[clearItem release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
    [super viewDidUnload];
}

- (void)dealloc {
    [targetLanguage release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Data

- (void)setTargetLanguage:(NSString *)lang {
    [targetLanguage autorelease];
    targetLanguage = [lang copy];
    
    [[NSUserDefaults standardUserDefaults] setObject:lang forKey:@"language"];
    [titleItem setSubtitle:[self targetLanguage]];
}

- (NSString *)currentText {
	return textView.text;
}

- (void)setCurrentText:(NSString *)currentText {
	textView.text = currentText;
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

- (void)doubleNavigationViewWasTapped:(id)dnv {
    LanguageSelectViewController *lang = [[LanguageSelectViewController alloc] initWithNibName:@"LanguageSelectView" bundle:nil];
    [lang setLanguages:[[[Pastie languages] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [lang setSelected:targetLanguage];
    [lang setDelegate:self];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:lang];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popover = [[objc_getClass("UIPopoverController") alloc] initWithContentViewController:nav];
        [popover presentPopoverFromRect:[self.navigationController.navigationBar frame] inView:[self.navigationController view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentModalViewController:nav animated:YES];
    }
    
    [nav release];
    [lang release];
}

- (void)languageSelectController:(LanguageSelectViewController *)lvc didSelectLanguage:(NSString *)language {
    self.targetLanguage = language;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popover dismissPopoverAnimated:YES];
        [popover release];
        popover = nil;
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) [self beginSubmission]; // Retry paste.
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
	
	[pastie beginSubmissionWithText:[textView text] makePrivate:self.makePrivate language:[[[Pastie languages] objectForKey:self.targetLanguage] intValue]];
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
