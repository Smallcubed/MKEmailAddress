//
//  MKEmailAddress.h
//  EmailAddressParser
//
//  Created by smorr on 2015-01-15.
//  Copyright (c) 2015 Indev Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#if __has_feature(objc_generics)
#define MKEmailAddressArray NSArray <MKEmailAddress*>
#define MKEmailAddressMutableArray NSMutableArray <MKEmailAddress*>
#else
#define MKEmailAddressArray NSArray
#define MKEmailAddressMutableArray NSMutableArray
#endif

@interface MKEmailAddress:NSObject <NSCopying>

@property (strong) NSString * _Nullable addressComment;
@property (strong) NSString * _Nullable userName;
@property (strong) NSString * _Nullable domain;
@property (strong) NSString * _Nullable invalidRawAddress;

@property (readonly) NSString * _Nullable displayAddress;
@property (readonly) NSString * _Nullable invertedDisplayAddress;
@property (readonly) NSString * _Nullable userAtDomain;
@property (readonly) NSString * _Nullable displayName;
@property (readonly) NSString * _Nullable digest;
@property (readonly) NSString * _Nullable rfc2822Representation;
@property (readonly) BOOL valid;

- (instancetype _Nullable)initWithAddressComment:(NSString * _Nullable)commentPart userName:(NSString * _Nonnull)userPart domain:(NSString * _Nonnull)domainPart;
- (instancetype _Nullable)initWithRawAddress:(NSString * _Nonnull)rawAddress;

+ (MKEmailAddressArray * _Nullable)emailAddressesFromHeaderValue:(NSString * _Nonnull)headerValue;
+ (MKEmailAddress * _Nullable)emailAddressWithRawAddress:(NSString * _Nonnull)rawAddress;
+ (MKEmailAddress * _Nullable)emailAddressWithComment:(NSString * _Nullable)commentPart userName:(NSString * _Nonnull)userPart domain:(NSString * _Nonnull)domainPart;
+ (MKEmailAddress * _Nullable)emailAddressWithABPerson:(ABPerson * _Nonnull)person forIdentifier:(NSString * _Nonnull)identifier;

+ (NSString * _Nullable)rfc2822RepresentationForAddresses:(MKEmailAddressArray * _Nonnull)addresses;

@end

