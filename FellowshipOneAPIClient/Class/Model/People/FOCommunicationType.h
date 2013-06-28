//
//  FOCommunicationType.h
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/28/13.
//
//

#import <Foundation/Foundation.h>

@interface FOCommunicationType : NSObject<NSCoding> {
	NSString *url;
	NSInteger myId;
	NSString *name;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger myId;
@property (nonatomic, copy) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (FOCommunicationType *)populateFromDictionary:(NSDictionary *)dict;

/* Gets all the communication types -- This method is performed synchronously -- */
+ (NSArray *)getAll;

// Get a contribution type from the API based on the communication type id
+ (FOCommunicationType *) getByID: (NSInteger)typeID;

// Get a contribution type from the API based on the communication type id ascynchornously
+ (void) getByID: (NSInteger)typeID usingCallback:(void (^)(FOCommunicationType *))returnedCommunicationType;

@end
