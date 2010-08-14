//
//  Pastie.m
//  Paste
//
//  Created by Grant Paul on 7/5/10.
//  Copyright 2010 Xuzz Productions. All rights reserved.
//

#import "Pastie.h"

#define kHeaderBoundary @"_xuzz_productions_paste_"

@implementation Pastie

@synthesize delegate;

- (void)beginSubmissionWithText:(NSString *)text {
	NSMutableDictionary *post_dict = [NSMutableDictionary dictionary];
	[post_dict setObject:text forKey:@"paste[body]"];
	[post_dict setObject:@"burger" forKey:@"paste[authorization]"];
	[post_dict setObject:@"1" forKey:@"paste[restricted]"];
	[post_dict setObject:@"6" forKey:@"paste[parser_id]"];
	
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(submissionFailedWithError:)])
		[delegate submissionFailedWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([delegate respondsToSelector:@selector(submissionCompletedWithURL:)])
		[delegate submissionCompletedWithURL:[response URL]];
}

@end
 