//
//  PasteAppDelegate.h
//  Paste
//
//  Created by Grant Paul on 7/5/10.
//  Copyright Xuzz Productions 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Pastie;
@class PasteViewController;

@interface PasteAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PasteViewController *viewController;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PasteViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

