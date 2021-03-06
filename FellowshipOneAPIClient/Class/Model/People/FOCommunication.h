/*
 Copyright (C) 2010 Fellowship Technologies. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 
 FellowshipOneAPIClient is a Cocoa Touch static library responsibile for constrcuting
 well formed signed OAuth requests to the Fellowship One API. The library promises to 
 eliminate the need to understand the inner workings of OAuth and signing to allow 
 developers to quickly get up and running building cocoa touch applications that
 integrate with the Fellowship One API
 
 For more information on OAUTH, please visit http://www.oauth.net
 
 For more information on the Fellowship One API, please visit http://developer.fellowshipone.com/docs/
 
 */

/* 
 
 inferface purpose: In order to use the fellowship one api, the first steps is to acquire an access token from the server
 The purpose here is to provide all methods necessary to logging into the API and gaining an access token along with providing
 some global methods
 
 */

#import <Foundation/Foundation.h>

@class FOCommunicationType;
@class FOParentObject;

@interface FOCommunication : NSObject <NSCoding> {
	NSString *url;
	NSInteger myId;
	NSString *value;
	NSString *comment;
	BOOL listed;
	NSDate *lastUpdatedDate;
    NSDate *createdDate;
	NSInteger typeId;
	NSString *typeName;
	NSString *generalType;
	NSString *cleansedValue;
    FOCommunicationType *communicationType;
    FOParentObject *household;
    FOParentObject *person;
    @private NSDictionary *_serializationMapper;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger myId;
// BEGIN Depricated - Use household instead
@property (nonatomic, assign, readonly) NSInteger householdId;
@property (nonatomic, assign, readonly) NSString *householdUrl;
// END Depricated
// BEGIN Depricated - Use person instead
@property (nonatomic, assign, readonly) NSInteger personId;
@property (nonatomic, assign, readonly) NSString *personUrl;
// END Depricated 
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, assign) BOOL listed;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSDate *lastUpdatedDate;
// BEGIN Depricated - Use communicationType instead
@property (nonatomic, assign, readonly) NSInteger typeId;
@property (nonatomic, assign, readonly) NSString *typeName;
// END Depricated
@property (nonatomic, copy) NSString *generalType;
@property (nonatomic, copy) NSString *cleansedValue;
@property (nonatomic, readonly) NSString *urlScheme;
@property (nonatomic, retain)	FOCommunicationType *communicationType;
@property (nonatomic, retain) FOParentObject *person;
@property (nonatomic, retain) FOParentObject *household;

/* maps the properties in this class to the required properties and order from an API request.
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

/* Gets all the communications associated with a specific person id -- This method is performed synchronously -- */
+ (NSArray *) getByPersonID: (NSInteger) personID;

/* Gets all the communications associated with a specific household id -- This method is performed synchronously -- */
+ (NSArray *) getByHouseholdID: (NSInteger) householdID;

/* Calls the API to save the current communication. If there is an ID attached to the communication, the method assumes an update, if no id exists, the method assumes create */
- (BOOL) save:(NSError **)error;

/* Calls the API to save the current communication. If there is an ID attached to the communication, the method assumes an update, if no id exists, the method assumes create */
- (void) saveUsingCallback:(void (^)(FOCommunication *))returnCommunication error:(void (^)(NSError *))errorBlock;

/* Gets an FT Communication from the F1 API based on the provided address id -- This method is performed synchronously -- */
+ (FOCommunication *) getByCommunicationID: (NSInteger) communicationID;

/* populates an FTCommunication object from a NSDictionary */
+ (FOCommunication *)populateFromDictionary: (NSDictionary *)dict;

@end