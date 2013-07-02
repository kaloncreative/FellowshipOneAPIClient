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
    NSDictionary *_serializationMapper;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger myId;
@property (nonatomic, copy) NSString *name;

/* maps the properties in this class to the required properties and order from an API request.
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (FOCommunicationType *)populateFromDictionary:(NSDictionary *)dict;

/* Gets all the communication types -- This method is performed synchronously -- */
+ (NSArray *)getAll;

// Get a contribution type from the API based on the communication type id
+ (FOCommunicationType *) getByID: (NSInteger)typeID;

// Get a contribution type from the API based on the communication type id ascynchornously
+ (void) getByID: (NSInteger)typeID usingCallback:(void (^)(FOCommunicationType *))returnedCommunicationType;

@end
