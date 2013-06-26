//
//  FOFund.m
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/26/13.
//
//

#import "FOFund.h"
#import "FOFundType.h"
#import "JSON.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "ConsoleLog.h"
#import "NSString+URLEncoding.h"
#import "NSObject+serializeToJSON.h"
#import <objc/runtime.h>

@implementation FOFund

@synthesize url, myId, name;
@synthesize fundCode;
@synthesize isActive, isWebEnabled;
@synthesize createdDate, lastUpdatedDate;
@synthesize fundType;

+ (FOFund *) populateFromDictionary:(NSDictionary *)dict {
    
	return [[[FOFund alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.name = [dict objectForKey:@"name"];
	self.fundCode = [dict objectForKey:@"fundCode"];
	if ([self.fundCode isEqual:[NSNull null]]) {
		self.fundCode = nil;
	}
    
    self.createdDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"createdDate"]];
    self.lastUpdatedDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"lastUpdatedDate"]];
    
    self.isWebEnabled = [[dict objectForKey:@"isWebEnabled"] boolValue];
    self.isActive = [[dict objectForKey:@"isActive"] boolValue];
    
    self.fundType = [FOFundType populateFromDictionary:[dict objectForKey:@"fundType"]];
    
	return self;
}

- (void) dealloc {
	[url release];
	[name release];
	[super dealloc];
}

#pragma mark -
#pragma mark Find

+ (FOFund *) getByID: (NSInteger)fundID {
    
    FOFund *returnFund = [[[FOFund alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"Funds/%d.json", fundID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"fund"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			returnFund = [FOFund populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnFund;
}

+ (void) getByID: (NSInteger)fundID usingCallback:(void (^)(FOFund *))returnedFund
{
    
	NSString *urlSuffix = [NSString stringWithFormat:@"Funds/%d.json", fundID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOFund *tmpFund = [[FOFund alloc] init];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpFund = [[FOFund alloc] initWithDictionary:[result.returnData objectForKey:@"fund"]];
            }
        }
        returnedFund(tmpFund);
        [tmpFund release];
        [oauth release];
    }];
}

+ (NSArray *)getAll
{
    NSMutableArray *returnFunds = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = @"Funds.json";
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"funds"];
		if (![topLevel isEqual:[NSNull null]]) {
			NSArray *funds = [topLevel objectForKey:@"fund"];
			
			for (NSDictionary *currentFund in funds) {
				[returnFunds addObject:[FOFund populateFromDictionary:currentFund]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnFunds;
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOFund alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.name = [coder decodeObjectForKey:@"name"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeObject:name forKey:@"name"];
}

@end
