//
//  FOContributionReceipt.h
//  FellowshipOneAPIClient
//
//  Created by Austin Grigg on 6/26/13.
//
// Required Fields:
//
// fund/@id
// receivedDate
// contributiontype/@id

#import <Foundation/Foundation.h>

@class FOFund;
@class FOContributionType;
@class FOHousehold;
@class FOPerson;

@interface FOContributionReceipt : NSObject <NSCoding> {
    NSInteger myId;
    NSString *url;
    NSNumber *amount;
    BOOL thank;
    BOOL addressVerification;
    BOOL isSplit;
    NSString *memo;
    NSDate *receivedDate;
    NSDate *transmitDate;
    NSDate *returnDate;
    NSDate *retransmitDate;
    NSDate *glPostDate;
    NSDate *thankedDate;
    NSDate *createdDate;
    NSDate *lastUpdatedDate;
    FOFund *fund;
    FOContributionType *contributionType;
    FOPerson *person;
    FOHousehold *household;
}

@property (nonatomic, assign)	NSInteger myId;
@property (nonatomic, copy)		NSString *url;
@property (nonatomic, retain)     NSNumber *amount;
@property (nonatomic, assign)   BOOL thank;
@property (nonatomic, assign)   BOOL addressVerification;
@property (nonatomic, assign)   BOOL isSplit;
@property (nonatomic, copy)     NSString *memo;
@property (nonatomic, retain)	NSDate *receivedDate; // Required
@property (nonatomic, retain)	NSDate *transmitDate;
@property (nonatomic, retain)	NSDate *returnDate;
@property (nonatomic, retain)	NSDate *retransmitDate;
@property (nonatomic, retain)	NSDate *glPostDate;
@property (nonatomic, retain)	NSDate *thankedDate;
@property (nonatomic, retain)	NSDate *createdDate; // Set by server
@property (nonatomic, retain)	NSDate *lastUpdatedDate;
@property (nonatomic, retain)	FOFund *fund;  // Required
@property (nonatomic, retain)	FOContributionType *contributionType;  // Required
@property (nonatomic, retain)	FOPerson *person;
@property (nonatomic, retain)	FOHousehold *household;

// Returns an FOContributionReceipt object ascynchronously
// @receiptID :: The ID of the contribution receipt to be returned
// @returnedReceipt :: The contribution receipt that is returned in the callback
+ (void) getByID: (NSInteger)receiptID usingCallback:(void (^)(FOContributionReceipt *))returnedReceipt;

// Returns an FOContributionReceipt object scynchronously
// @receiptID :: The ID of the contribution receipt to be returned
+ (FOContributionReceipt *) getByID: (NSInteger)receiptID;

// Search the F1 database for contribution receipts -- This method is performed asynchronously --
// qo: The query object that tells the api what to search on
// pageNumber: the page number the search is for
//+ (void) searchForContributionReceipts: (FOFOContributionReceiptQO *)qo usingCallback:(void (^)(FOPagedEntity *))pagedResults;

// Populates an FOContributionReceipt object from a NSDictionary
+(FOContributionReceipt *) populateFromDictionary: (NSDictionary *)dict;

@end
