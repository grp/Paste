//
//  Pastie.h
//  Paste
//
//  Created by Grant Paul on 7/5/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
// 

#import <Foundation/Foundation.h>

@protocol PastieDelegate;

@interface Pastie : NSObject {
	id<PastieDelegate> delegate;
}

@property (nonatomic, assign) id<PastieDelegate> delegate;

+ (NSDictionary *)languages;

- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)private language:(NSInteger)language;
- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)makePrivate;
- (void)beginSubmissionWithText:(NSString *)text;

@end

@protocol PastieDelegate <NSObject>
@optional
- (void)submissionCompletedWithURL:(NSURL *)url;
- (void)submissionFailedWithError:(NSError *)error;
@end
