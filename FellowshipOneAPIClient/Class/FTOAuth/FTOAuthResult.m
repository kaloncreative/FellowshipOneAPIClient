//
//  FTOAuthResult.m
//  Fellowship
//
//  Created by Chad Meyer on 5/4/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

#import "FTOAuthResult.h"
#import "FTOAuth.h"



@implementation FTOAuthResult


@synthesize returnData;
@synthesize isSucceed;
@synthesize returnImageData;
@synthesize error, responseBody, responseStatusCode;

- (void) dealloc
{
	[returnData release];
	[returnImageData release];
    [responseBody release];
    [error release];
	[super dealloc];
}

@end
