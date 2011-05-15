//
//  LanguageSelectViewController.m
//  Paste
//
//  Created by Grant Paul on 12/19/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
//

#import "LanguageSelectViewController.h"


@implementation LanguageSelectViewController
@synthesize languages;
@synthesize selected;
@synthesize tableView;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Languages"];
    [self.navigationItem setPrompt:@"Select language to paste as."];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] 
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
            target:self
            action:@selector(doneTapped)
        ] autorelease]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [tableView reloadData];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[languages indexOfObject:selected] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [tableView flashScrollIndicators];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [languages count];
}

- (void)updateCell:(UITableViewCell *)cell forSelectedState:(BOOL)sel {
    
    [[cell textLabel] setTextColor:sel ? [UIColor purpleColor] : [UIColor blackColor]];
    [cell setAccessoryType:sel ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];    
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *language = [languages objectAtIndex:indexPath.row];
    BOOL sel = [language isEqualToString:selected];
    
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"LanguageCell"];
	if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LanguageCell"] autorelease];
	
    [[cell textLabel] setText:language];
    [self updateCell:cell forSelectedState:sel];
    
	return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *old = [self.selected autorelease];
    NSString *new = [self.languages objectAtIndex:indexPath.row];
    [self setSelected:new];
    
    UITableViewCell *oldCell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.languages indexOfObject:old] inSection:0]];
    [self updateCell:oldCell forSelectedState:NO];
    UITableViewCell *newCell = [table cellForRowAtIndexPath:indexPath];
    [self updateCell:newCell forSelectedState:YES];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([delegate respondsToSelector:@selector(languageSelectController:didSelectLanguage:)])
        [delegate languageSelectController:self didSelectLanguage:self.selected];
}

- (void)doneTapped {
    if ([delegate respondsToSelector:@selector(languageSelectController:didSelectLanguage:)])
        [delegate languageSelectController:self didSelectLanguage:self.selected];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)dealloc {
    [languages release];
    [selected release];
    
    [super dealloc];
}

@end
