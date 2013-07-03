//
//  FOFund.h
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/26/13.
//
//

#import <Foundation/Foundation.h>

@class FOFundType;

@interface FOFund : NSObject<NSCoding> {
	NSString *url;
	NSInteger myId;
	NSString *name;
    NSString *fundCode;
    FOFundType *fundType;
    BOOL isWebEnabled;
    BOOL isActive;
    NSDate *createdDate;
    NSDate *lastUpdatedDate;
    NSDictionary *_serializationMapper;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger myId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fundCode;
@property (nonatomic, assign)   BOOL isWebEnabled;
@property (nonatomic, assign)   BOOL isActive;
@property (nonatomic, retain)	FOFundType *fundType;
@property (nonatomic, retain)	NSDate *createdDate;
@property (nonatomic, retain)	NSDate *lastUpdatedDate;

/* maps the properties in this class to the required properties and order from an API request.
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (FOFund *)populateFromDictionary:(NSDictionary *)dict;

/* Gets all the funds -- This method is performed synchronously -- */
+ (NSArray *)getAll;

// Get a fund type from the API based on the fund id
+ (FOFund *) getByID: (NSInteger)fundID;

// Get a fund from the API based on the fund id ascynchornously
+ (void) getByID: (NSInteger)fundID usingCallback:(void (^)(FOFund *))returnedFund;

@end
