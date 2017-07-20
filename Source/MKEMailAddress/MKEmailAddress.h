//
//  MKEmailAddress.h
//  EmailAddressParser
//
//  Created by smorr on 2015-01-15.
//  Copyright (c) 2015 Indev Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
@class MKEmailAddress;

#if __has_feature(objc_generics)

#define MKEmailAddressArray NSArray <MKEmailAddress*>
#define MKEmailAddressMutableArray NSMutableArray <MKEmailAddress*>

#else

#define MKEmailAddressArray NSArray
#define MKEmailAddressMutableArray NSMutableArray

#endif

@interface MKEmailAddress:NSObject <NSCopying>

@property (strong) NSString * addressComment;
@property (strong) NSString * userName;
@property (strong) NSString * domain;
@property (strong) NSString * invalidRawAddress;

@property (readonly) NSString * displayAddress;
@property (readonly) NSString * userAtDomain;
@property (readonly) NSString * displayName;
@property (readonly) NSString * digest;
@property (readonly) NSString * rfc2822Representation;
@property (readonly) BOOL valid;

- (instancetype)initWithAddressComment:(NSString *)commentPart userName:(NSString *) userPart domain:(NSString *)domainPart ;
- (instancetype)initWithCommentedAddress:(NSString *)commentedAddress;
+ (NSString *)rfc2822RepresentationForAddresses:(MKEmailAddressArray *)addresses;
+ (MKEmailAddressArray *)emailAddressesFromHeaderValue:(NSString *)headerValue;
+ (MKEmailAddress *) addressWithComment:(NSString *)commentPart userName:(NSString *) userPart domain:(NSString *)domainPart;
+ (MKEmailAddress *)addressWithABPerson:(ABPerson *)person forIdentifier:(NSString *)identifier;


@end

