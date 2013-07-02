//
//  Person.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/17/09.
//  Copyright 2009 Fellowship Technologies. All rights reserved.
//

#import "FOPerson.h"
#import "JSON.h"
#import "FOHouseholdMemberType.h"
#import "FOStatus.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "NSDate+ageFromDate.h"
#import "FOPagedEntity.h"
#import "ConsoleLog.h"
#import "FOAddress.h"
#import "FOCommunication.h"
#import "FOParentNamedObject.h"
#import "FOPersonQO.h"
#import "NSString+URLEncoding.h"
#import "NSObject+serializeToJSON.h"
#import <objc/runtime.h>

@interface FOPerson (PRIVATE)

+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching;
+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage;

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage;
- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching;
- (id)initWithDictionary:(NSDictionary *)dict;
@end


@implementation FOPerson

@synthesize myId, householdId;
@synthesize url;
@synthesize firstName, middleName, lastName, goesByName, suffix, title, prefix, salutation, formerName;
@synthesize maritalStatus;
@synthesize gender;
@synthesize dateOfBirth;
@synthesize imageURL;
@synthesize rawImage;
@synthesize firstRecord;
@synthesize createdDate;
@synthesize lastUpdatedDate;
@synthesize householdMemberType;
@synthesize status;
@synthesize addresses;
@synthesize communications;
@synthesize isAuthorized;

- (NSDictionary *)serializationMapper {
	
	if (!_serializationMapper) {
		
		NSMutableDictionary *mapper = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *attributeKeys = [[NSMutableDictionary alloc] init];
		NSArray *attributeOrder = [[NSArray alloc] initWithObjects:@"myId", @"url", @"householdId", nil];
		
		[mapper setObject:attributeOrder forKey:@"attributeOrder"];
		[attributeOrder release];
		
		[attributeKeys setValue:@"@uri" forKey:@"url"];
		[attributeKeys setValue:@"@id" forKey:@"myId"];
		[attributeKeys setValue:@"@householdID" forKey:@"householdId"];
		
		[mapper setObject:attributeKeys forKey:@"attributes"];
		[attributeKeys release];
		
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"title", @"salutation", @"prefix", @"firstName", @"lastName", @"suffix", @"middleName", @"goesByName", @"formerName", @"gender", @"dateOfBirth", @"maritalStatus", @"householdMemberType", @"isAuthorized", @"status", @"occupation", @"employer", @"school", @"denomination", @"formerChurch", @"barCode", @"memberEnvelopeCode", @"defaultTagComment", @"weblink", @"solicit", @"thank", @"firstRecord", @"lastMatchDate", @"createdDate", @"lastUpdatedDate",nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		//[mapper setValue:@"imageURI" forKey:@"imageURL"];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
	}
	
	return _serializationMapper;
}

#pragma mark Additional Properties

// NOT IMPLEMENTED Placeholder for save
- (NSDictionary *)occupation
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"", @"name", @"", @"description", nil];
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)employer
{
    return @"";
}

// NOT IMPLEMENTED Placeholder for save
- (NSDictionary *)school
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"", @"name", nil];
}

// NOT IMPLEMENTED Placeholder for save
- (NSDictionary *)denomination
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"", @"name", nil];
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)formerChurch
{
    return @"";
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)barCode
{
    return @"";
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)memberEnvelopeCode
{
    return @"";
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)defaultTagComment
{
    return @"";
}

// NOT IMPLEMENTED Placeholder for save
- (NSDictionary *)weblink
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"", @"userID", @"", @"passwordHint", @"", @"passwordAnswer", nil];
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)solicit
{
    return @"";
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)thank
{
    return @"";
}

// NOT IMPLEMENTED Placeholder for save
- (NSString *)lastMatchDate
{
    return @"";
}

//- (id)valueForUndefinedKey:(NSString *)key
//{
//    
//}

- (NSString *)casualName {
	NSMutableString *name;
	
	if (self.goesByName != nil) {
		name = [NSMutableString stringWithString:self.goesByName];
	}
	else {
		name = [NSMutableString stringWithString:self.firstName];
	}
	
	[name appendString:@" "];
	[name appendString:self.lastName];
	
	if (self.suffix != nil) {
		[name appendString:@", "];
		[name appendString:self.suffix];
	}
	
	return name;
}

- (NSString *)lastNameFirstName {
    NSMutableString *name = [NSMutableString new];
	
    if(self.lastName != nil){
        [name appendString:self.lastName];
        [name appendString:@", "];
    }
    
    if (self.goesByName != nil) {
		[name appendString:self.goesByName];
	}
	else if(self.firstName != nil) {
		[name appendString:self.firstName];
	}

	return name;

}

- (NSString *)age {
	if (self.dateOfBirth) {
		
		NSInteger ageInYears = [self.dateOfBirth ageFromDate];
		
		if (ageInYears > 0) {
			return [NSString stringWithFormat:@"%i yrs.", ageInYears];
		}
		else {
			return @"child";
		}
	}
	
	return @"";	
}

#pragma mark -
#pragma mark PRIVATE populate methods

+(FOPerson *)populateFromDictionary: (NSDictionary *)dict {
	
	return [FOPerson populateFromDictionary:dict searching:NO];
}

+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching {
	
	return [[[FOPerson alloc] initWithDictionary:dict searching:searching] autorelease];
}

+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage {
	return [[[FOPerson alloc] initWithDictionary:dict searching:searching preloadImage:preloadImage] autorelease];
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
	
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.url = [dict objectForKey:@"@uri"];
	self.householdId = [[dict objectForKey:@"@householdID"] integerValue];
	self.firstName = [dict objectForKey:@"firstName"];
	self.lastName = [dict objectForKey:@"lastName"];
	
	self.goesByName = [dict objectForKey:@"goesByName"];
	if ([self.goesByName isEqual:[NSNull null]]) {
		self.goesByName = nil;
	}
	
	self.suffix = [dict objectForKey:@"suffix"];
	if ([self.suffix isEqual:[NSNull null]]) {
		self.suffix = nil;
	}
	
	self.imageURL = [dict objectForKey:@"@imageURI"];
	
    self.isAuthorized = [[dict objectForKey:@"isAuthorized"] boolValue];
    
    // Address collection
    NSDictionary *addressResults = [dict objectForKey:@"addresses"];
    
    if (addressResults && ![addressResults isKindOfClass:[NSNull class]]) {
        NSMutableArray *addressArray = [[NSMutableArray alloc] initWithObjects:nil];
        for (NSDictionary *addressResult in [addressResults objectForKey:@"address"]) {
            [addressArray addObject:[FOAddress populateFromDictionary:addressResult]];
        }
        self.addresses = [addressArray copy];
        [addressArray release];
    }
    
    // communication collection
    NSDictionary *communicationResults = [dict objectForKey:@"communications"];
    
    if (communicationResults && ![communicationResults isKindOfClass:[NSNull class]]) {
        NSMutableArray *communicationArray = [[NSMutableArray alloc] initWithObjects:nil];
        for (NSDictionary *communicationResult in [communicationResults objectForKey:@"communication"]) {
            [communicationArray addObject:[FOCommunication populateFromDictionary:communicationResult]];
        }
        self.communications = [communicationArray copy];
        [communicationArray release];
    }
    
	
	if (!searching) {
		
		if (preloadImage) {
			if (self.imageURL.length == 0) {
				self.imageURL = nil;
			}
			else {
				self.rawImage = [self getImageData:@"S"];
			}
		}
    }
		
		
    self.gender = [dict objectForKey:@"gender"];
    if ([self.gender isEqual:[NSNull null]]) {
        self.gender = nil;
    }
    
    self.title = [dict objectForKey:@"title"];
    if ([self.title isEqual:[NSNull null]]) {
        self.title = nil;
    }
    
    self.prefix = [dict objectForKey:@"prefix"];
    if ([self.prefix isEqual:[NSNull null]]) {
        self.prefix = nil;
    }
    
    self.salutation = [dict objectForKey:@"salutation"];
    if ([self.salutation isEqual:[NSNull null]]) {
        self.salutation = nil;
    }
    
    self.dateOfBirth = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"dateOfBirth"]];
    
    self.maritalStatus = [dict objectForKey:@"maritalStatus"];
    if ([self.maritalStatus isEqual:[NSNull null]]) {
        self.maritalStatus = nil;
    }
    
    self.formerName = [dict objectForKey:@"formerName"];
    if ([self.formerName isEqual:[NSNull null]]) {
        self.formerName = nil;
    }
    
    self.firstRecord = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"firstRecord"]];
    self.createdDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"createdDate"]];
    self.lastUpdatedDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"lastUpdatedDate"]];
    self.householdMemberType = [FOHouseholdMemberType populateFromDictionary:[dict objectForKey:@"householdMemberType"]];
    self.status = [FOStatus populateFromDictionary:[dict objectForKey:@"status"]];
	
	return self;
}

+ (NSString *) getSearchIncludeString:(PeopleSearchInclude)include {
	
	@try {
		switch (include) {
			case (int)PeopleSearchIncludeAddresses:
				return @"addresses";
				break;
			case (int)PeopleSearchIncludeCommunications:
				return @"communications";
				break;
			case (int)PeopleSearchIncludeAttributes:
				return @"attributes";
				break;
			default:
				return @"";
				break;
		}
	}
	@catch (NSException * e) {
		[ConsoleLog LogMessage:[NSString stringWithFormat:@"Could not find people search include %@. Error returned %@", include, e]];
		return @"";
	}
	@finally { }
}

#pragma mark -
#pragma mark Helpers

- (NSData *) getImageData: (NSString *)size {
    NSData *rawData = nil;
	
	if (self.imageURL) {
		NSMutableString *imageFullURL = [NSString stringWithFormat:@"%@?size=%@", self.imageURL, size];
		
		NSURL *nsImageURL = [NSURL URLWithString:imageFullURL];
		
        FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
		FTOAuthResult *result = [oauth callSyncFTAPIWithURL:nsImageURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
		
		if (result.isSucceed) {
			rawData = [result.returnImageData retain];
		}
        [oauth release];
	}	
	
	return rawData;
}

#pragma mark -
#pragma mark Find

+ (void) getByID: (NSInteger)personID usingCallback:(void (^)(FOPerson *))returnedPerson {
    
    NSString *personURL = [NSString stringWithFormat:@"People/%d.json", personID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOPerson *tmpPerson = [[FOPerson alloc] init];
 
    [oauth callFTAPIWithURLSuffix:personURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpPerson = [[FOPerson alloc] initWithDictionary:[result.returnData objectForKey:@"person"]];
            }
        }
        returnedPerson(tmpPerson);
        [tmpPerson release];
        [oauth release];
    }];
}


+ (FOPerson *) getByID: (NSInteger)personID {
    
    FOPerson *returnPerson = [[[FOPerson alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"People/%d.json", personID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"person"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			returnPerson = [FOPerson populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnPerson;    
}

+ (FOPerson *) getByUrl: (NSString *)theUrl {
    FOPerson *returnPerson = [[[FOPerson alloc] init] autorelease];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURL:[NSURL URLWithString:theUrl] forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"person"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			returnPerson = [FOPerson populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnPerson;   
    
}

+ (void) getByUrl: (NSString *)theUrl usingCallback:(void (^)(FOPerson *))returnedPerson {
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOPerson *tmpPerson = [[FOPerson alloc] init];
    
    [oauth callFTAPIWithURL:theUrl withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpPerson = [[FOPerson alloc] initWithDictionary:[result.returnData objectForKey:@"person"]];
            }
        }
        returnedPerson(tmpPerson);
        [tmpPerson release];
        [oauth release];
    }];
    
}

+ (void) searchForPeople: (FOPersonQO *) qo usingCallback:(void (^)(FOPagedEntity *))pagedResults {
	
	NSMutableString *peopleSearchURL = [NSMutableString stringWithFormat:@"People/Search.json%@", [qo createQueryString]];
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    
	    
    [oauth callFTAPIWithURLSuffix:peopleSearchURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        FOPagedEntity *resultsEntity = [[FOPagedEntity alloc] init];
        NSMutableArray *tmpResults = [[NSMutableArray alloc] initWithObjects:nil];
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                
                NSDictionary *topLevel = [result.returnData objectForKey:@"results"];
                NSArray *results = [topLevel objectForKey:@"person"];

                resultsEntity.currentCount = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@count"]];
                resultsEntity.pageNumber = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@pageNumber"]];
                resultsEntity.totalRecords = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@totalRecords"]];
                resultsEntity.additionalPages = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@additionalPages"]];
                
                for (NSDictionary *result in results) {
                    [tmpResults addObject:[FOPerson populateFromDictionary:result searching:YES]];
                }
                
                resultsEntity.results = [tmpResults copy];
            }
        }
        pagedResults(resultsEntity);
        [resultsEntity release];
        [tmpResults release];
        [oauth release];
    }];
}

+ (NSArray *) getByHouseholdID: (NSInteger) householdID {
	
	NSMutableArray *returnPeople = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = [NSString stringWithFormat:@"Households/%d/People.json", householdID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"people"];
		if (![topLevel isEqual:[NSNull null]]) {
			NSArray *people = [topLevel objectForKey:@"person"];
			
			for (NSDictionary *currentPerson in people) {
				[returnPeople addObject:[FOCommunication populateFromDictionary:currentPerson]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnPeople;
}

+ (void)getImageData: (NSInteger)personID withSize:(NSString *)size usingCallback:(void (^)(NSData *))returnedImage {
    NSString *imageURL = [NSString stringWithFormat:@"People/%d/Images.json?Size=%@", personID, size];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block NSData *tmpImage = [[NSData alloc] init];
    
    [oauth callFTAPIWithURLSuffix:imageURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpImage = result.returnImageData;
            }
        }
        returnedImage(tmpImage);
        [tmpImage release];
        [oauth release];
    }];
}

- (BOOL)save:(NSError **)error {
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	HTTPMethod method = HTTPMethodPOST;
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"People"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
	
    NSData *data = [[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding];
    
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix
															forRealm:FTAPIRealmBase
													  withHTTPMethod:method
															withData:data];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"person"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			[self initWithDictionary:topLevel];
		}
        
        //[ftOAuthResult release];
        [oauth release];
        
        return YES;
	}
    else {
        if(error != NULL){
            *error = ftOAuthResult.error;
        }
        //[ftOAuthResult release];
        [oauth release];
        return NO;
    }
}

- (void) saveUsingCallback:(void (^)(FOPerson *))returnPerson error:(void (^)(NSError *))errorBlock {
    
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOPerson *tmpPerson = [[FOPerson alloc] init];
    HTTPMethod method = HTTPMethodPOST;
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"People"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:method withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding] usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpPerson = [[FOPerson alloc] initWithDictionary:[result.returnData objectForKey:@"person"]];
                returnPerson(tmpPerson);
            }
            else {
                errorBlock(result.error);
            }
        }
        else {
            errorBlock([NSError errorWithDomain:@"F1" code:4 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Response was not a FTOAuthResult", NSLocalizedDescriptionKey, nil]]);
        }
        [tmpPerson release];
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
	[url release];
	[firstName release];
	[middleName release];
	[lastName release];
	[suffix release];
	[title release];
	[prefix release];
	[gender release];
	[salutation release];
	[maritalStatus release];
	[formerName release];
	[dateOfBirth release];
	[imageURL release];
	[firstRecord release];
	[createdDate release];
	[lastUpdatedDate release];
	[householdMemberType release];
	[status release];
	[rawImage release];
    [addresses release];
    [communications release];
    [_serializationMapper release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOPerson alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.householdId = [coder decodeIntegerForKey:@"householdId"];
		self.firstName = [coder decodeObjectForKey:@"firstName"];
		self.middleName = [coder decodeObjectForKey:@"middleName"];
		self.goesByName = [coder decodeObjectForKey:@"goesByName"];
		self.lastName = [coder decodeObjectForKey:@"lastName"];
		self.suffix = [coder decodeObjectForKey:@"suffix"];
		self.title = [coder decodeObjectForKey:@"title"];
		self.prefix = [coder decodeObjectForKey:@"prefix"];
		self.gender = [coder decodeObjectForKey:@"gender"];
		self.salutation = [coder decodeObjectForKey:@"salutation"];
		self.maritalStatus = [coder decodeObjectForKey:@"maritalStatus"];
		self.formerName = [coder decodeObjectForKey:@"formerName"];
		self.dateOfBirth = [coder decodeObjectForKey:@"dateOfBirth"];
		self.imageURL = [coder decodeObjectForKey:@"imageURL"];
		self.firstRecord = [coder decodeObjectForKey:@"firstRecord"];
		self.createdDate = [coder decodeObjectForKey:@"createdDate"];
		self.lastUpdatedDate = [coder decodeObjectForKey:@"lastUpdatedDate"];
		self.householdMemberType = [coder decodeObjectForKey:@"householdMemberType"];
		self.status = [coder decodeObjectForKey:@"status"];
		self.rawImage = [coder decodeObjectForKey:@"rawImage"];
        self.addresses = [coder decodeObjectForKey:@"addresses"];
        self.communications = [coder decodeObjectForKey:@"communications"];
	}
    
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeInteger:householdId forKey:@"householdId"];
	[coder encodeObject:firstName forKey:@"firstName"];
	[coder encodeObject:middleName forKey:@"middleName"];
	[coder encodeObject:lastName forKey:@"lastName"];
	[coder encodeObject:suffix forKey:@"suffix"];
	[coder encodeObject:title forKey:@"title"];
	[coder encodeObject:prefix forKey:@"prefix"];
	[coder encodeObject:gender forKey:@"gender"];
	[coder encodeObject:salutation forKey:@"salutation"];
	[coder encodeObject:maritalStatus forKey:@"maritalStatus"];
	[coder encodeObject:formerName forKey:@"formerName"];
	[coder encodeObject:dateOfBirth forKey:@"dateOfBirth"];
	[coder encodeObject:imageURL forKey:@"imageURL"];
	[coder encodeObject:firstRecord forKey:@"firstRecord"];
	[coder encodeObject:createdDate forKey:@"createdDate"];
	[coder encodeObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
	[coder encodeObject:householdMemberType forKey:@"householdMemberType"];
	[coder encodeObject:status forKey:@"status"];
	[coder encodeObject:rawImage forKey:@"rawImage"];
    [coder encodeObject:addresses forKey:@"addresses"];
    [coder encodeObject:communications forKey:@"communications"];
}

@end