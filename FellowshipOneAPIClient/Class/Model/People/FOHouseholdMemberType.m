
//
//  HouseholdMemberType.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FOHouseholdMemberType.h"


@implementation FOHouseholdMemberType

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
		
		[mapper setValue:@"name" forKey:@"name"];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
		
	}
	
	return _serializationMapper;
}

+ (FOHouseholdMemberType *) populateFromDictionary:(NSDictionary *)dict {
    
	return [[[FOHouseholdMemberType alloc] initWithDictionary:dict] autorelease];
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
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOHouseholdMemberType alloc] init];
	
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
