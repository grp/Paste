//
//  Pastie.m
//  Paste
//
//  Created by Grant Paul on 7/5/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
//

#import "Pastie.h"

#define kHeaderBoundary @"_xuzz_productions_paste_"

@implementation Pastie
@synthesize delegate;

+ (NSDictionary *)languages {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:2],  @"ActionScript",
            [NSNumber numberWithInt:13], @"Bash (shell)",
            [NSNumber numberWithInt:20], @"C#",
            [NSNumber numberWithInt:7],  @"C/C++",
            [NSNumber numberWithInt:8],  @"CSS",
            [NSNumber numberWithInt:5],  @"Diff",
            [NSNumber numberWithInt:21], @"Go",
            [NSNumber numberWithInt:12], @"HTML (ERB / Rails)",
            [NSNumber numberWithInt:11], @"HTML / XML",
            [NSNumber numberWithInt:9],  @"Java",
            [NSNumber numberWithInt:10], @"JavaScript",
            [NSNumber numberWithInt:1],  @"Objective-C/C++",
            [NSNumber numberWithInt:18], @"Perl",
            [NSNumber numberWithInt:15], @"PHP",
            [NSNumber numberWithInt:6],  @"Plain Text",
            [NSNumber numberWithInt:16], @"Python", 
            [NSNumber numberWithInt:3],  @"Ruby", 
            [NSNumber numberWithInt:4],  @"Ruby on Rails", 
            [NSNumber numberWithInt:14], @"SQL", 
            [NSNumber numberWithInt:19], @"YAML",  
    nil];
}

- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)private language:(NSInteger)language {
	NSMutableDictionary *post_dict = [NSMutableDictionary dictionary];
	[post_dict setObject:text forKey:@"paste[body]"];
	[post_dict setObject:@"burger" forKey:@"paste[authorization]"];
	[post_dict setObject:private ? @"1" : @"0" forKey:@"paste[restricted]"];
	[post_dict setObject:[NSString stringWithFormat:@"%d", language] forKey:@"paste[parser_id]"];
	
	NSMutableData *post_data = [NSMutableData data];
	for (NSString *key in [post_dict allKeys]) {
		[post_data appendData:[[NSString stringWithFormat:@"--%@\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[post_dict valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[post_data appendData:[[NSString stringWithFormat:@"--%@--\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://pastie.org/pastes"]];
	NSString *content_type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHeaderBoundary];
	[request addValue:content_type forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:post_data];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)private {
    [self beginSubmissionWithText:text makePrivate:private language:[[[[self class] languages] objectForKey:@"Plain Text"] intValue]];
}

- (void)beginSubmissionWithText:(NSString *)text {
    [self beginSubmissionWithText:text makePrivate:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(submissionFailedWithError:)])
		[delegate submissionFailedWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([delegate respondsToSelector:@selector(submissionCompletedWithURL:)])
		[delegate submissionCompletedWithURL:[response URL]];
}

@end
 