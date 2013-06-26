//
//  FOContributionType.h
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/26/13.
//
//

#import <Foundation/Foundation.h>

@interface FOContributionType : NSObject<NSCoding> {
	NSString *url;
	NSInteger myId;
	NSString *name;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger myId;
@property (nonatomic, copy) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (FOContributionType *)populateFromDictionary:(NSDictionary *)dict;

/* Gets all the contribution types -- This method is performed synchronously -- */
+ (NSArray *)getAll;

// Get a contribution type from the API based on the contribution type id
+ (FOContributionType *) getByID: (NSInteger)typeID;

// Get a contribution type from the API based on the contribution type id ascynchornously
+ (void) getByID: (NSInteger)typeID usingCallback:(void (^)(FOContributionType *))returnedContributionType;

@end
