//
//  Pastie.h
//  Paste
//
//  Created by Grant Paul on 7/5/10.
//  Copyright 2010 Xuzz Productions. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface Pastie : NSObject {
	id delegate;
}

@property (nonatomic, assign) id delegate;

- (void)beginSubmissionWithText:(NSString *)text;

@end
