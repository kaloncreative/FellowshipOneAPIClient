//
//  FOContributionReceipt.m
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/26/13.
//
//

#import "FOContributionReceipt.h"
#import "FOPerson.h"
#import "FOHousehold.h"
#import "FOContributionType.h"
#import "FOFund.h"
#import "JSON.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "FOPagedEntity.h"
#import "ConsoleLog.h"
#import "NSString+URLEncoding.h"
#import "NSObject+serializeToJSON.h"
#import <objc/runtime.h>

@interface FOContributionReceipt (PRIVATE)

+(FOContributionReceipt *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching;

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching;
- (id)initWithDictionary:(NSDictionary *)dict;
@end

@implementation FOContributionReceipt

@synthesize myId;
@synthesize url;
@synthesize amount;
@synthesize thank, addressVerification, isSplit;
@synthesize memo;
@synthesize receivedDate;
@synthesize transmitDate;
@synthesize returnDate;
@synthesize retransmitDate;
@synthesize glPostDate;
@synthesize thankedDate;
@synthesize createdDate;
@synthesize lastUpdatedDate;
@synthesize fund;
@synthesize contributionType;
@synthesize person;
@synthesize household;

#pragma mark -
#pragma mark PRIVATE populate methods

+(FOContributionReceipt *)populateFromDictionary: (NSDictionary *)dict {
	
	return [FOContributionReceipt populateFromDictionary:dict searching:NO];
}

+(FOContributionReceipt *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching {
	
	return [[[FOContributionReceipt alloc] initWithDictionary:dict searching:searching] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	return [self initWithDictionary:dict searching:NO];
}

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching {
	if (![super init]) {
		return nil;
	}
	
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.url = [dict objectForKey:@"@uri"];
	self.amount = [NSNumber numberWithDouble:[[dict objectForKey:@"amount"] doubleValue]];
	
    self.thank = [[dict objectForKey:@"thank"] boolValue];
    self.addressVerification = [[dict objectForKey:@"addressVerification"] boolValue];
    self.isSplit = [[dict objectForKey:@"isSplit"] boolValue];
    
    self.memo = [dict objectForKey:@"memo"];
    if ([self.memo isEqual:[NSNull null]]) {
		self.memo = nil;
	}
    
    self.receivedDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"receivedDate"]];
    self.transmitDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"transmitDate"]];
    self.returnDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"returnDate"]];
    self.retransmitDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"retransmitDate"]];
    self.glPostDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"glPostDate"]];
    self.thankedDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"thankedDate"]];
    
    self.createdDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"createdDate"]];
    self.lastUpdatedDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"lastUpdatedDate"]];
    
    self.fund = [FOFund populateFromDictionary:[dict objectForKey:@"fund"]];
    self.contributionType = [FOContributionType populateFromDictionary:[dict objectForKey:@"contributionType"]];
    self.person = [FOPerson populateFromDictionary:[dict objectForKey:@"person"]];
    self.household = [FOHousehold populateFromDictionary:[dict objectForKey:@"household"]];
	
	return self;
}

#pragma mark -
#pragma mark Find

+ (void) getByID: (NSInteger)receiptID usingCallback:(void (^)(FOContributionReceipt *))returnedReceipt {
    
    NSString *receiptURL = [NSString stringWithFormat:@"ContributionReceipts/%d.json", receiptID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOContributionReceipt *tmpReceipt = [[FOContributionReceipt alloc] init];
    
    [oauth callFTAPIWithURLSuffix:receiptURL forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpReceipt = [[FOContributionReceipt alloc] initWithDictionary:[result.returnData objectForKey:@"contributionReceipt"]];
            }
        }
        returnedReceipt(tmpReceipt);
        [tmpReceipt release];
        [oauth release];
    }];
}


+ (FOContributionReceipt *) getByID: (NSInteger)receiptID {
    
    FOContributionReceipt *returnReceipt = [[[FOContributionReceipt alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"ContributionReceipts/%d.json", receiptID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"contributionReceipt"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			returnReceipt = [FOContributionReceipt populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnReceipt;
}

+ (FOContributionReceipt *) getByUrl: (NSString *)theUrl {
    FOContributionReceipt *returnReceipt = [[[FOContributionReceipt alloc] init] autorelease];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURL:[NSURL URLWithString:theUrl] forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"contributionReceipt"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			returnReceipt = [FOContributionReceipt populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnReceipt;
    
}

+ (void) getByUrl: (NSString *)theUrl usingCallback:(void (^)(FOContributionReceipt *))returnedReceipt {
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOContributionReceipt *tmpReceipt = [[FOContributionReceipt alloc] init];
    
    [oauth callFTAPIWithURL:theUrl withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpReceipt = [[FOContributionReceipt alloc] initWithDictionary:[result.returnData objectForKey:@"contributionReceipt"]];
            }
        }
        returnedReceipt(tmpReceipt);
        [tmpReceipt release];
        [oauth release];
    }];
    
}

//+ (void) searchForContributionReceipts: (FOFOContributionReceiptQO *) qo usingCallback:(void (^)(FOPagedEntity *))pagedResults {
//	
//	NSMutableString *peopleSearchURL = [NSMutableString stringWithFormat:@"People/Search.json%@", [qo createQueryString]];
//	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
//    
//    
//    [oauth callFTAPIWithURLSuffix:peopleSearchURL forRealm:FTAPIRealmGiving withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
//        
//        FOPagedEntity *resultsEntity = [[FOPagedEntity alloc] init];
//        NSMutableArray *tmpResults = [[NSMutableArray alloc] initWithObjects:nil];
//        
//        if ([block isKindOfClass:[FTOAuthResult class]]) {
//            FTOAuthResult *result = (FTOAuthResult *)block;
//            if (result.isSucceed) {
//                
//                NSDictionary *topLevel = [result.returnData objectForKey:@"results"];
//                NSArray *results = [topLevel objectForKey:@"contributionReceipt"];
//                
//                resultsEntity.currentCount = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@count"]];
//                resultsEntity.pageNumber = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@pageNumber"]];
//                resultsEntity.totalRecords = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@totalRecords"]];
//                resultsEntity.additionalPages = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@additionalPages"]];
//                
//                for (NSDictionary *result in results) {
//                    [tmpResults addObject:[FOContributionReceipt populateFromDictionary:result searching:YES]];
//                }
//                
//                resultsEntity.results = [tmpResults copy];
//            }
//        }
//        pagedResults(resultsEntity);
//        [resultsEntity release];
//        [tmpResults release];
//        [oauth release];
//    }];
//}

- (void) save {
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	HTTPMethod method = HTTPMethodPOST;
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"ContributionReceipts"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
	
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix
															forRealm:FTAPIRealmGiving
													  withHTTPMethod:method
															withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"contributionReceipt"];
		
		if (![topLevel isEqual:[NSNull null]]) {
			[self initWithDictionary:topLevel];
		}
	}
    
    [ftOAuthResult release];
    [oauth release];
}

- (void) saveUsingCallback:(void (^)(FOContributionReceipt *))returnReceipt {
    
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOContributionReceipt *tmpReceipt = [[FOContributionReceipt alloc] init];
    HTTPMethod method = HTTPMethodPOST;
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"ContributionReceipts"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmGiving withHTTPMethod:method withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding] usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpReceipt = [[FOContributionReceipt alloc] initWithDictionary:[result.returnData objectForKey:@"contributionReceipt"]];
            }
        }
        returnReceipt(tmpReceipt);
        [tmpReceipt release];
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
	[amount release];
	[memo release];
    [receivedDate release];
    [transmitDate release];
    [returnDate release];
    [retransmitDate release];
    [glPostDate release];
    [thankedDate release];
	[createdDate release];
	[lastUpdatedDate release];
    [fund release];
    [contributionType release];
    [person release];
    [household release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOContributionReceipt alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.createdDate = [coder decodeObjectForKey:@"createdDate"];
		self.lastUpdatedDate = [coder decodeObjectForKey:@"lastUpdatedDate"];
	}
    
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:self.url forKey:@"url"];
	[coder encodeInteger:self.myId forKey:@"myId"];
	[coder encodeObject:self.createdDate forKey:@"createdDate"];
	[coder encodeObject:self.lastUpdatedDate forKey:@"lastUpdatedDate"];
}

@end
