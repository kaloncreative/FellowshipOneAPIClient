
#import "FOStatus.h"
#import "FOSubStatus.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "ConsoleLog.h"
#import "NSString+URLEncoding.h"
#import "NSObject+serializeToJSON.h"
#import <objc/runtime.h>

@implementation FOStatus

@synthesize url, myId, name, comment, date, subStatus;

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
		
        //TODO: Add in subStatus
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"name", @"comment", @"date", @"subStatus", nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		[mapper setValue:@"name" forKey:@"name"];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
		
	}
	
	return _serializationMapper;
}

+ (FOStatus *)populateFromDictionary: (NSDictionary *)dict {
	return [[[FOStatus alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.name = [dict objectForKey:@"name"];
	// optional
	self.comment = [dict objectForKey:@"comment"];
	if ([self.comment isEqual:[NSNull null]]) {
		self.comment = nil;
	}
    
    self.date = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"date"]];
	
	if ([dict objectForKey:@"subStatus"] != nil) {
		NSDictionary *tempSubStatus = [dict objectForKey:@"subStatus"];
		NSString *tempName = [tempSubStatus objectForKey:@"name"];
		if (![tempName isEqual:[NSNull null]]) {
			self.subStatus = [[[FOSubStatus alloc] initWithDictionary:[dict objectForKey:@"subStatus"]] autorelease];
		}
		else {
			self.subStatus = nil; 
		}
	}
	
	return self;
}

+ (NSArray *)getAll
{
    NSMutableArray *returnTypes = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = @"People/Statuses.json";
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"statuses"];
		if (![topLevel isEqual:[NSNull null]]) {
			NSArray *types = [topLevel objectForKey:@"status"];
			
			for (NSDictionary *currentTYpe in types) {
				[returnTypes addObject:[FOStatus populateFromDictionary:currentTYpe]];
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

- (void) dealloc {
	
	self.url = nil;
	self.comment = nil;
	self.date = nil;
	self.subStatus = nil;
	self.name = nil;
	
	[url release];
	[comment release];
	[date release];
	[subStatus release];
	[name release];
	[_serializationMapper release];
    
	[super dealloc];
    
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOStatus alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.comment = [coder decodeObjectForKey:@"comment"];
		self.date = [coder decodeObjectForKey:@"date"];
		self.subStatus = [coder decodeObjectForKey:@"substatus"];
		self.name = [coder decodeObjectForKey:@"name"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeObject:comment forKey:@"comment"];
	[coder encodeObject:date forKey:@"date"];
	[coder encodeObject:subStatus forKey:@"subStatus"];
	[coder encodeObject:name forKey:@"name"];
}


@end