//
//  PasteAppDelegate.m
//  Paste
//
//  Created by Grant Paul on 7/5/10.
//  Copyright Xuzz Productions 2010. All rights reserved.
//

#import "PasteAppDelegate.h"
#import "PasteViewController.h"
#import "Pastie.h"

@implementation PasteAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    	
	[navigationController setViewControllers:[NSArray arrayWithObject:viewController]];
	
	[window makeKeyAndVisible];
	[window addSubview:navigationController.view]; 
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	viewController.currentText = [[UIPasteboard generalPasteboard] string];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	viewController.currentText = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[window release];
	[navigationController release];
	[viewController release];
	
	[super dealloc];
}


@end

