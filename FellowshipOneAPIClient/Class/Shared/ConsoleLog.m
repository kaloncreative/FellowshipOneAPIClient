//
//  ConsoleLog.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConsoleLog.h"

NSInteger gFOLogVerbosity = 0;

@implementation ConsoleLog

+ (void) LogMessage:(NSString *)message {
    [self logWithVerbosity:FOLogVerbosityEveryStep information:message];
}

#pragma mark - Verbosity
+ (NSInteger)verbosity
{
    return gFOLogVerbosity;
}

+ (void)setVerbosity:(NSInteger)verbosity
{
    gFOLogVerbosity = verbosity;
}

#pragma mark - Logging
+ (void)logWithVerbosity:(NSInteger)someVerbosity formatString:(NSString *)formatString args:(va_list)args
{
    if( someVerbosity > [self verbosity] ) {
        return;
    }
    
    NSLogv(formatString, args);
}

+ (void)logWithVerbosity:(NSInteger)someVerbosity information:(NSString *)formatString, ...
{
    va_list args;
    va_start(args, formatString);
    [self logWithVerbosity:someVerbosity formatString:formatString args:args];
    va_end(args);
}

@end
