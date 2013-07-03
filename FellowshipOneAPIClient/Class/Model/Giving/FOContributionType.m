//
//  FOContributionType.m
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/26/13.
//
//

#import "FOContributionType.h"
#import "JSON.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "ConsoleLog.h"
#import "NSString+URLEncoding.h"
#import "NSObject+serializeToJSON.h"
#import <objc/runtime.h>

@implementation FOContributionType

@synthesize url, myId, name;

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

+ (FOContributionType *) populateFromDictionary:(NSDictionary *)dict {
    
	return [[[FOContributionType alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.name = [dict objectForKey:@"name"];
	
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

+ (FOContributionType *) getByID: (NSInteger)typeID {
    
    FOContributionType *returnType = [[[FOContributionType alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"ContributionTypes/%d.json", typeID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"contributionType"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			returnType = [FOContributionType populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnType;
}

+ (void) getByID: (NSInteger)typeID usingCallback:(void (^)(FOContributionType *))returnedContributionType
{
    
	NSString *urlSuffix = [NSString stringWithFormat:@"ContributionTypes/%d.json", typeID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOContributionType *tmpType = [[FOContributionType alloc] init];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpType = [[FOContributionType alloc] initWithDictionary:[result.returnData objectForKey:@"contributionType"]];
            }
        }
        returnedContributionType(tmpType);
        [tmpType release];
        [oauth release];
    }];
}

+ (NSArray *)getAll
{
    NSMutableArray *returnTypes = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = @"ContributionTypes.json";
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"contributionTypes"];
		if (![topLevel isEqual:[NSNull null]]) {
			NSArray *types = [topLevel objectForKey:@"contributionType"];
			
			for (NSDictionary *currentTYpe in types) {
				[returnTypes addObject:[FOContributionType populateFromDictionary:currentTYpe]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnTypes;
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
	
	self = [[FOContributionType alloc] init];
	
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
