//
//  Person.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/17/09.
//  Copyright 2009 Fellowship Technologies. All rights reserved.
//

#import "FOAccount.h"
#import "JSON.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "NSDate+ageFromDate.h"
#import "FOPagedEntity.h"
#import "ConsoleLog.h"
#import "NSString+URLEncoding.h"
#import "NSObject+serializeToJSON.h"
#import <objc/runtime.h>

@interface FOAccount (PRIVATE)

+(FOAccount *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching;

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching;
- (id)initWithDictionary:(NSDictionary *)dict;

@end


@implementation FOAccount

@synthesize firstName, lastName, email, urlRedirect;

#pragma mark - Save JSON Serialization Helpers

- (NSDictionary *)serializationMapper {
	
	if (!_serializationMapper) {
		
		NSMutableDictionary *mapper = [[NSMutableDictionary alloc] init];
		
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"firstName", @"lastName", @"email", @"urlRedirect",nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
	}
	
	return _serializationMapper;
}

#pragma mark -
#pragma mark PRIVATE populate methods

+(FOAccount *)populateFromDictionary: (NSDictionary *)dict {
	
	return [FOAccount populateFromDictionary:dict searching:NO];
}

+(FOAccount *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching {
	
	return [[[FOAccount alloc] initWithDictionary:dict searching:searching] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	return [self initWithDictionary:dict searching:NO];
}

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching {
	return [self initWithDictionary:dict searching:searching preloadImage:YES];
}

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage {
	if (![super init]) {
		return nil;
	}
	
	self.firstName = [dict objectForKey:@"firstName"];
	self.lastName = [dict objectForKey:@"lastName"];
	self.email = [dict objectForKey:@"email"];
    	
	return self;
}

- (BOOL)create:(NSError **)error {
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	HTTPMethod method = HTTPMethodPOST;
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"Accounts"];
	
	[urlSuffix appendString:@".json"];
    
	
    NSData *data = [[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding];
    
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix
															forRealm:FTAPIRealmBase
													  withHTTPMethod:method
															withData:data];
	
	if (ftOAuthResult.isSucceed) {
		
        [oauth release];
        
        return YES;
	}
    else {
        if(error != NULL){
            *error = ftOAuthResult.error;
        }
        [oauth release];
        return NO;
    }
}

- (void) createUsingCallback:(void (^)())successBlock error:(void (^)(NSError *))errorBlock {
    
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    HTTPMethod method = HTTPMethodPOST;
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"Accounts"];
	
	[urlSuffix appendString:@".json"];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:method withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding] usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                successBlock();
            }
            else {
                errorBlock(result.error);
            }
        }
        else {
            errorBlock([NSError errorWithDomain:@"F1" code:4 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Response was not a FTOAuthResult", NSLocalizedDescriptionKey, nil]]);
        }
        [oauth release];
    }];
}

- (NSString *)description
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++)
    {
        NSString *selector = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
        
        SEL sel = sel_registerName([selector UTF8String]);
        
        const char *attr = property_getAttributes(properties[i]);
        switch (attr[1]) {
            case '@':
                [string appendString:[NSString stringWithFormat:@"%s : %@\n", property_getName(properties[i]), objc_msgSend(self, sel)]];
                break;
            case 'i':
                [string appendString:[NSString stringWithFormat:@"%s : %i\n", property_getName(properties[i]), objc_msgSend(self, sel)]];
                break;
            case 'f':
                [string appendString:[NSString stringWithFormat:@"%s : %f\n", property_getName(properties[i]), objc_msgSend(self, sel)]];
                break;
            default:
                break;
        }
    }
    
    free(properties);
    
    return string;
    
}

- (void) dealloc {
	[firstName release];
	[lastName release];
	[email release];
    [urlRedirect release];
    [_serializationMapper release];
	    
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOAccount alloc] init];
	
	if (self != nil) {
		self.firstName = [coder decodeObjectForKey:@"firstName"];
        self.lastName = [coder decodeObjectForKey:@"lastName"];
		self.email = [coder decodeObjectForKey:@"email"];
        self.urlRedirect = [coder decodeObjectForKey:@"urlRedirect"];
	}
    
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:firstName forKey:@"firstName"];
	[coder encodeObject:lastName forKey:@"lastName"];
	[coder encodeObject:email forKey:@"email"];
    [coder encodeObject:urlRedirect forKey:@"urlRedirect"];
}

@end