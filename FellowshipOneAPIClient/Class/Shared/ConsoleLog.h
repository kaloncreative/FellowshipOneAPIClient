//
//  ConsoleLog.h
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/** `ConsoleLog` is a utility class to provide the primary logging behavior for the `FellowshipOneAPIClient` framework.
 
 To see output logged by the framework, set the verbosity greater than `0`:
 
 [ConsoleLog setVerbosity:<verbosityLevel>];
 
 The higher the level, the more information you will see in the console. Examine the `FOLogVerbosity` entries for specific values.
 */

/** @name Logging */
/** Verbosity for Logging debugging output
 */
typedef NS_ENUM(NSInteger, FOLogVerbosity)
{
    FOLogVerbosityNoLogging = 0,
    FOLogVerbosityErrorsOnly = 1,
    FOLogVerbosityErrorsAndWarnings = 9,
    FOLogVerbosityEveryStep = 100,
};

#define FOLog(verbosity,...) [ConsoleLog logWithVerbosity:verbosity information:[NSString stringWithFormat:@"%s : %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]]]

@interface ConsoleLog : NSObject {

}

+ (void) LogMessage:(NSString *)message;

/** @name Verbosity */

/** Returns the current verbosity level for logging. */
+ (NSInteger)verbosity;

/** Sets the verbosity level for logging.
 
 @param verbosity The verbosity level to use; specify `FOLogVerbosityEveryStep` to see all output */
+ (void)setVerbosity:(NSInteger)verbosity;

/** @name Logging */

/** Log some information (assuming `DEBUG` is set).
 
 @param someVerbosity The verbosity level of this information (if the current verbosity is less than this, the information won't be logged).
 @param formatString The format string (using `NSLog()` format specifiers).
 @param ... A comma-separated list of arguments to substitute into `formatString`.
 */
+ (void)logWithVerbosity:(NSInteger)someVerbosity information:(NSString *)formatString, ...;

/** Log some information (assuming `DEBUG` is set).
 
 @param someVerbosity The verbosity level of this information (if the current verbosity is less than this, the information won't be logged).
 @param formatString The format string (using `NSLog()` format specifiers).
 @param args A correctly started `va_list` with the arguments to substitute into `formatString`.
 */
+ (void)logWithVerbosity:(NSInteger)someVerbosity formatString:(NSString *)formatString args:(va_list)args;

@end
