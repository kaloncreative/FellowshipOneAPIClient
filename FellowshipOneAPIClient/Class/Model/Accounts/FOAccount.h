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
 
 inferface purpose: FOPerson is the person object for the fellowship one api. 
 You may get more information by going to https://demo.fellowshiponeapi.com/v1/people.help
 
 */

#import <Foundation/Foundation.h>

@interface FOAccount : NSObject <NSCoding> {
    
	NSString				*firstName;
	NSString				*lastName;
	NSString				*email;
    NSString                *urlRedirect;
    
    @private NSDictionary *_serializationMapper;
}

@property (nonatomic, copy)		NSString *firstName;
@property (nonatomic, copy)		NSString *lastName;
@property (nonatomic, copy)		NSString *email;
@property (nonatomic, copy)		NSString *urlRedirect;

/* maps the properties in this class to the required properties and order from an API request.
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

/* Calls the API to save the current person. If there is an ID attached to the person, the method assumes an update, if no id exists, the method assumes create */
- (BOOL)create:(NSError **)error;

/* Calls the API to save the current person. If there is an ID attached to the person, the method assumes an update, if no id exists, the method assumes create */
- (void) createUsingCallback:(void (^)())successBlock error:(void (^)(NSError *))errorBlock;

// Populates an FOAccount * object from a NSDictionary
+(FOAccount *) populateFromDictionary: (NSDictionary *)dict;

@end
