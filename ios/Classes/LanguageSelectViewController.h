//
//  LanguageSelectViewController.h
//  Paste
//
//  Created by Grant Paul on 12/19/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LanguageSelectDelegate;

@interface LanguageSelectViewController : UIViewController {
    NSArray *languages;
    NSString *selected;
    UITableView *tableView;
    id<LanguageSelectDelegate> delegate;
}

@property (nonatomic, copy) NSArray *languages;
@property (nonatomic, copy) NSString *selected;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<LanguageSelectDelegate> delegate;

@end

@protocol LanguageSelectDelegate<NSObject>
@optional
- (void)languageSelectController:(LanguageSelectViewController *)lvc didSelectLanguage:(NSString *)language;
@end