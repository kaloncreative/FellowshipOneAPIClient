//
//  Communication.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FOCommunication.h"
#import "JSON.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "NSObject+serializeToJSON.h"
#import "FOCommunicationType.h"
#import "FOParentObject.h"

@interface FOCommunication (PRIVATE)

- (id)initWithDictionary:(NSDictionary *)dict;

@end


@implementation FOCommunication

@synthesize url;
@synthesize myId;
@synthesize householdId, householdUrl;
@synthesize personId;
@synthesize personUrl;
@synthesize value;
@synthesize comment;
@synthesize listed;
@synthesize createdDate, lastUpdatedDate;
@synthesize typeId, typeName;
@synthesize cleansedValue, generalType;
@synthesize communicationType;
@synthesize person, household;

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
		
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"household", @"person", @"communicationType", @"generalType", @"value", @"cleansedValue", @"listed", @"comment", @"createdDate", @"lastUpdatedDate",nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		[mapper setValue:@"communicationGeneralType" forKey:@"generalType"];
		[mapper setValue:@"communicationValue" forKey:@"value"];
		[mapper setValue:@"searchCommunicationValue" forKey:@"cleansedValue"];
		[mapper setValue:@"communicationComment" forKey:@"comment"];
        [mapper setValue:@"preferred" forKey:@"listed"];
		[mapper setValue:@"lastUpdatedDate" forKey:@"lastUpdatedDate"];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
	}
	
	return _serializationMapper;
}

+ (FOCommunication *)populateFromDictionary: (NSDictionary *)dict {
	
	return [[[FOCommunication alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	
    self.household = [FOParentObject populateFromDictionary:[dict objectForKey:@"household"]];
    
	self.person = [FOParentObject populateFromDictionary:[dict objectForKey:@"person"]];
	
	self.value = [dict objectForKey:@"communicationValue"];
	
	self.comment = [dict objectForKey:@"communicationComment"];
	if ([self.comment isEqual:[NSNull null]]) {
		self.comment = nil;
	}
    
    self.createdDate = [FellowshipOneAPIDateUtility dateFromString:[dict objectForKey:@"createdDate"]];
	
	NSString *tempLastUpdatedDate = [dict objectForKey:@"lastUpdatedDate"];
	if ([tempLastUpdatedDate isEqual:[NSNull null]]) {
		self.lastUpdatedDate = nil;
	}
	else {
		self.lastUpdatedDate = [FellowshipOneAPIDateUtility dateFromString:tempLastUpdatedDate];
	}
	
	self.listed = [[dict objectForKey:@"listed"] boolValue];
	self.cleansedValue = [dict objectForKey:@"searchCommunicationValue"];	
	self.generalType = [dict objectForKey:@"communicationGeneralType"];
    
    self.communicationType = [FOCommunicationType populateFromDictionary:[dict objectForKey:@"communicationType"]];
    
	return self;
}

- (NSInteger)typeId
{
    if(self.communicationType == nil)
        return NSIntegerMin;
    
    return self.communicationType.myId;
}

- (NSString *)typeName
{
    if(self.communicationType == nil)
        return nil;
    
    return self.communicationType.name;
}

- (NSInteger)householdId
{
    if(self.household == nil)
        return NSIntegerMin;
    
    return self.household.myId;
}

- (NSString *)householdUrl
{
    if(self.household == nil)
        return nil;
    
    return self.household.url;
}

- (NSInteger)personId
{
    if(self.person == nil)
        return NSIntegerMin;
    
    return self.person.myId;
}

- (NSString *)personUrl
{
    if(self.person == nil)
        return nil;
    
    return self.person.url;
}

#pragma mark Read-only properties

- (NSString *)urlScheme {
	NSString *theScheme = self.value;
	
	if ([self.generalType isEqualToString:@"Telephone"]) {
		theScheme = [NSString stringWithFormat:@"tel://%@", self.cleansedValue];
	}
	else if ([self.generalType isEqualToString:@"Email"]) {
		theScheme = [NSString stringWithFormat:@"mailto://%@", self.value];
	}
	else {
		if (![self.value hasPrefix:@"http"]) {
			theScheme = [@"http://" stringByAppendingString:self.value];
		}
	}
	
	return theScheme;
}

#pragma mark -

#pragma mark Find

+ (NSArray *) getByPersonID: (NSInteger) personID {
	
	NSMutableArray *returnCommunications = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = [NSString stringWithFormat:@"People/%d/Communications.json", personID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"communications"];
		if (![topLevel isEqual:[NSNull null]]) {	
			NSArray *communications = [topLevel objectForKey:@"communication"];
			
			for (NSDictionary *currentCommunication in communications) {
				[returnCommunications addObject:[FOCommunication populateFromDictionary:currentCommunication]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnCommunications;
}

+ (NSArray *) getByHouseholdID: (NSInteger) householdID {
	
	NSMutableArray *returnCommunications = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = [NSString stringWithFormat:@"Households/%d/Communications.json", householdID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"communications"];
		if (![topLevel isEqual:[NSNull null]]) {
			NSArray *communications = [topLevel objectForKey:@"communication"];
			
			for (NSDictionary *currentCommunication in communications) {
				[returnCommunications addObject:[FOCommunication populateFromDictionary:currentCommunication]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnCommunications;
}

+ (FOCommunication *) getByCommunicationID: (NSInteger) communicationID {
	
	FOCommunication *returnCommunication = [[[FOCommunication alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"Communications/%d.json", communicationID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"communication"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			returnCommunication = [FOCommunication populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnCommunication;
	
}

- (void) save {
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	HTTPMethod method = HTTPMethodPOST;
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"People/%d/Communications", self.personId];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
	
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix
															forRealm:FTAPIRealmBase
													  withHTTPMethod:method
															withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"communication"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			[self initWithDictionary:topLevel];
		}
	}
    
    [ftOAuthResult release];
    [oauth release];
}

- (void) saveUsingCallback:(void (^)(FOCommunication *))returnCommunication {
    
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOCommunication *tmpCommunication = [[FOCommunication alloc] init];
    HTTPMethod method = HTTPMethodPOST;
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"People/%d/Communications", self.personId];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:method withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding] usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpCommunication = [[FOCommunication alloc] initWithDictionary:[result.returnData objectForKey:@"communication"]];
            }
        }
        returnCommunication(tmpCommunication);
        [tmpCommunication release];
        [oauth release];
    }];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOCommunication alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.household = [coder decodeObjectForKey:@"household"];
		self.person = [coder decodeObjectForKey:@"person"];
		self.value = [coder decodeObjectForKey:@"value"];
		self.comment = [coder decodeObjectForKey:@"comment"];
		self.listed = [coder decodeBoolForKey:@"listed"];
        self.createdDate = [coder decodeObjectForKey:@"createdDate"];
		self.lastUpdatedDate = [coder	decodeObjectForKey:@"lastUpdatedDate"];
		self.communicationType = [coder decodeObjectForKey:@"communicationType"];
		self.cleansedValue = [coder decodeObjectForKey:@"cleansedValue"];
		self.generalType = [coder decodeObjectForKey:@"generalType"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeObject:household forKey:@"household"];
	[coder encodeObject:person forKey:@"person"];
	[coder encodeObject:value forKey:@"value"];
	[coder encodeObject:comment forKey:@"comment"];
	[coder encodeBool:listed forKey:@"listed"];
    [coder encodeObject:createdDate forKey:@"createdDate"];
	[coder encodeObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
	[coder encodeObject:communicationType forKey:@"communicationType"];
	[coder encodeObject:cleansedValue forKey:@"cleansedValue"];
	[coder encodeObject:generalType forKey:@"generalType"];
}


#pragma mark -
#pragma mark Cleanup

- (void) dealloc {
	
	[url release];
	[household release];
	[person release];
	[value release];
	[comment release];
    [createdDate release];
	[lastUpdatedDate release];
	[typeName release];
	[generalType release];
	[cleansedValue release];
    [communicationType release];
    [_serializationMapper release];
	
	[super dealloc];
}

@end