//
//  FOSubFund.m
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/17/14.
//
//

#import "FOSubFund.h"
#import "FOParentNamedObject.h"
#import "JSON.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "ConsoleLog.h"
#import "NSString+URLEncoding.h"
#import "NSObject+serializeToJSON.h"
#import <objc/runtime.h>

@implementation FOSubFund

@synthesize url, myId, name;
@synthesize fundCode;
@synthesize isActive, isWebEnabled;
@synthesize createdDate, lastUpdatedDate;
@synthesize parentFund;

- (NSDictionary *)serializationMapper {
	
	if (!_serializationMapper) {
		
		NSMutableDictionary *mapper = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *attributeKeys = [[NSMutableDictionary alloc] init];
		NSArray *attributeOrder = [[NSArray alloc] initWithObjects:@"myId", @"url", nil];
		
		[mapper setObject:attributeOrder forKey:@"attributeOrder"];
		[attributeOrder release];
		
		[attributeKeys setValue:@"@uri" forKey:@"url"];
		[attributeKeys setValue:@"@id" forKey:@"myId"];
		
		[mapper setObject:attributeKeys forKey:@"attributes"];
		[attributeKeys release];
		
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"name", nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
		
	}
	
	return _serializationMapper;
}

+ (FOSubFund *) populateFromDictionary:(NSDictionary *)dict {
    
	return [[[FOSubFund alloc] initWithDictionary:dict] autorelease];
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
    
    self.parentFund = [FOParentNamedObject populateFromDictionary:[dict objectForKey:@"parentFund"]];
    
	return self;
}

- (void) dealloc {
	[url release];
	[name release];
    [_serializationMapper release];
	[super dealloc];
}

#pragma mark -
#pragma mark Find

+ (FOSubFund *) getByID: (NSInteger)subFundID parent:(NSInteger)parentFundID
{
    FOSubFund *returnFund = [[[FOSubFund alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"Funds/%d/subfunds/%d.json", parentFundID, subFundID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"subFund"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			returnFund = [FOSubFund populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnFund;
}

+ (void) getByID: (NSInteger)subFundID parent:(NSInteger)parentFundID usingCallback:(void (^)(FOSubFund *))returnedFund
{
    
	NSString *urlSuffix = [NSString stringWithFormat:@"Funds/%d/subfunds/%d.json", parentFundID, subFundID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOSubFund *tmpFund = [[FOSubFund alloc] init];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpFund = [[FOSubFund alloc] initWithDictionary:[result.returnData objectForKey:@"subFund"]];
            }
        }
        returnedFund(tmpFund);
        [tmpFund release];
        [oauth release];
    }];
}

+ (NSArray *)getAllForParent:(NSInteger)parentFundID
{
    NSMutableArray *returnFunds = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = [NSString stringWithFormat:@"Funds/%d/subfunds.json", parentFundID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"subfunds"];
		if (![topLevel isEqual:[NSNull null]]) {
			NSArray *subfunds = [topLevel objectForKey:@"subFund"];
			
			for (NSDictionary *currentSubFund in subfunds) {
				[returnFunds addObject:[FOSubFund populateFromDictionary:currentSubFund]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnFunds;
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

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOSubFund alloc] init];
	
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
