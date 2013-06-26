//
//  FOFundType.h
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/26/13.
//
//

#import <Foundation/Foundation.h>

@interface FOFundType : NSObject<NSCoding> {
	NSString *url;
	NSInteger myId;
	NSString *name;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger myId;
@property (nonatomic, copy) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (FOFundType *)populateFromDictionary:(NSDictionary *)dict;

/* Gets all the fund types -- This method is performed synchronously -- */
+ (NSArray *)getAll;

// Get a fund type from the API based on the fund type id
+ (FOFundType *) getByID: (NSInteger)typeID;

// Get a fund type from the API based on the fund type id ascynchornously
+ (void) getByID: (NSInteger)typeID usingCallback:(void (^)(FOFundType *))returnedFundType;

@end
