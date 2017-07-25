//
//  MKEmailAddress.m
//  EmailAddressParser
//
//  Created by smorr on 2015-01-15.
//  Copyright (c) 2015 Indev Software. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "MKEmailAddress.h"

#import "NSScanner+RFC2822.h"
#import "NSString+MimeEncoding.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>


@interface NSData (MKE_MKEmailAddress)
- (NSString *)MKEpathSafeBase64EncodedString;
@end

@interface NSString (MKE_MKEmailAddress)
- (NSString *)MKEshortSHAHashString;
@end


@implementation MKEmailAddress

#pragma mark - Instance Creation

- (instancetype)initWithAddressComment:(NSString *)commentPart userName:(NSString *)userPart domain:(NSString *)domainPart {
    self = [self init];
    if (self) {
        self.addressComment = commentPart;
        self.userName = userPart;
        self.domain = domainPart;
		
		BOOL isValid = YES;
		if ((domainPart.length == 0) || (userPart.length == 0)) {
			isValid = NO;
		}
		else {
			NSError * error = nil;
			NSString * domainRegExString = @"^(?:[A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$";
			NSRegularExpression * regEx = [NSRegularExpression regularExpressionWithPattern:domainRegExString options:NSRegularExpressionCaseInsensitive error:&error];
			if ([regEx numberOfMatchesInString:domainPart options:0 range:NSMakeRange(0, domainPart.length)] != 1) {
				isValid = NO;
			}
		}
		if (!isValid) {
			self.invalidRawAddress = [NSString stringWithFormat:@"%@ <", commentPart?:@""];
			self.invalidRawAddress = [self.invalidRawAddress stringByAppendingFormat:@"%@", userPart?:@""];
			if (domainPart) {
				self.invalidRawAddress = [self.invalidRawAddress stringByAppendingFormat:@"@%@", domainPart];
			}
			self.invalidRawAddress = [self.invalidRawAddress stringByAppendingString:@">"];
			self.addressComment = nil;
			self.userName = nil;
			self.domain = nil;
		}
    }
    return self;
}

- (instancetype)initWithRawAddress:(NSString *)rawAddress {
	NSString * displayName = nil;
	NSString * userName = nil;
	NSString * domain = nil;
	NSString * invalidPart = nil;
    if (rawAddress.length > 0) {
        NSScanner * scanner = [NSScanner scannerWithString:rawAddress];
        NSError * error = nil;
		[scanner scanRFC2822EmailAddressIntoDisplayName:&displayName localName:&userName domain:&domain invalid:&invalidPart error:&error];
    }
	if (invalidPart) {
		self = [self init];
		self.invalidRawAddress = invalidPart;
		return self;
	}
     if (userName && domain){
         return [self initWithAddressComment:displayName userName:userName domain:domain];
     }
     else{
         self = [self init];
         self.invalidRawAddress = rawAddress;
         return self;
     }
         
}


#pragma mark - Class Creation

+ (MKEmailAddress *)emailAddressWithComment:(NSString*)commentPart userName:(NSString*) userPart domain:(NSString*)domainPart {
	return [[[self class] alloc] initWithAddressComment:commentPart
											   userName:userPart
												 domain:domainPart];
}

+ (MKEmailAddress *)emailAddressWithRawAddress:(NSString *)rawAddress {
	return [[self alloc] initWithRawAddress:rawAddress];
}

+ (NSArray *)emailAddressesFromHeaderValue:(NSString *)headerValue {
	if (!headerValue) return nil;
	NSMutableArray * emailAddresses = [NSMutableArray array];
	@autoreleasepool {
		NSScanner * scanner = [NSScanner scannerWithString:headerValue];
		NSError * error = nil;
		while (![scanner isAtEnd] && !error) {
			NSString * displayName= nil;
			NSString * userName = nil;
			NSString * domain = nil;
			NSString * invalidPart = nil;
			error = nil;
			if ([scanner scanRFC2822EmailAddressIntoDisplayName:&displayName localName:&userName domain:&domain invalid:&invalidPart error:&error]) {
				MKEmailAddress * address = nil;
				if (invalidPart) {
					address = [MKEmailAddress new];
					address.invalidRawAddress = invalidPart;
				}
				else {
					NSString * decodedDisplayName = [displayName decodedMimeEncodedString];
					address = [[MKEmailAddress alloc] initWithAddressComment:decodedDisplayName userName:userName domain:domain];
				}
				[emailAddresses addObject:address];
			}
			else {
				NSLog(@"\n\t\t%@\n\t\t\t\tERROR: %@", headerValue, error);
				emailAddresses = nil;
				break;
			}
		}
	}
	return emailAddresses;
}

+ (NSString*)rfc2822RepresentationForAddresses:(MKEmailAddressArray *)addresses {
	NSMutableArray * rfc2822Reps = [NSMutableArray array];
	for (MKEmailAddress* anAddr in addresses){
		NSString * rfcRep = [anAddr rfc2822Representation];
		if (rfcRep){
			[rfc2822Reps addObject:rfcRep];
		}
	}
	if ([rfc2822Reps count]){
		return [rfc2822Reps componentsJoinedByString:@","];
	}
	return nil;
}

+ (MKEmailAddress *)emailAddressWithABPerson:(ABPerson *)person forIdentifier:(NSString *)identifier {
	NSString * useIdentifier = identifier;
	ABMultiValue * addressValues = [person valueForProperty:kABEmailProperty];
	if (useIdentifier.length == 0) {
		useIdentifier = addressValues.primaryIdentifier;
	}
	if (useIdentifier.length == 0) {
		return nil;
	}
	NSString * addressString = [addressValues valueForIdentifier:useIdentifier];
	NSRange atRange = [addressString rangeOfString:@"@"];
	NSString * displayName = [NSString stringWithFormat:@"%@ %@", [person valueForProperty:kABFirstNameProperty], [person valueForProperty:kABLastNameProperty]];
	NSString * userName = nil;
	NSString * domain = addressString;
    if (atRange.location != NSNotFound) {
        userName = [addressString substringToIndex:atRange.location];
        domain = [addressString substringFromIndex:(atRange.location + atRange.length)];
    }
    if (userName && domain){
        return [[self class] emailAddressWithComment:displayName userName:userName domain:domain];
    }
    else{
        return nil;
    }
}


#pragma mark - Accessors

- (NSString *)digest {
    NSString * stringToHash = [self rfc2822Representation];
    if (!stringToHash) {
        stringToHash = self.displayAddress;
    }
    if (!stringToHash) {
        stringToHash = self.invalidRawAddress;
    }
    return [stringToHash MKEshortSHAHashString];
}

- (NSString *)displayAddress {
	if (self.addressComment) {
		if (self.userAtDomain) {
			return [NSString stringWithFormat:@"%@ <%@>",self.addressComment,self.userAtDomain];
		}
	}
	else if(self.userAtDomain) {
		return self.userAtDomain;
	}
	return nil;
}

- (NSString *)invertedDisplayAddress {
	if (self.addressComment) {
		if (self.userAtDomain) {
			return [NSString stringWithFormat:@"%@ (%@)", self.userAtDomain, self.addressComment];
		}
	}
	else if(self.userAtDomain) {
		return self.userAtDomain;
	}
	return nil;
}

- (NSString *)description {
    NSString * commentedAddress = self.displayAddress;
    if (commentedAddress) {
        return [NSString stringWithFormat:@"<%@: %p> %@", [self class], self, commentedAddress];
    }
    else {
        return [NSString stringWithFormat:@"<%@: %p> (INVALID) %@", [self class], self, self.invalidRawAddress];
    }
}

- (NSString *)userAtDomain {
    if (self.userName && self.domain) {
        return [NSString stringWithFormat:@"%@@%@", self.userName, self.domain];
    }
    return nil;
}

- (NSString *)displayName {
    return [self.addressComment decodedMimeEncodedString]?:self.userAtDomain;
}

- (BOOL)valid {
	return (self.invalidRawAddress.length > 0)?NO:YES;
}


#pragma mark - NSCopying, Equality

- (MKEmailAddress *)copyWithZone:(NSZone*)aZone {
	return [[MKEmailAddress alloc] initWithAddressComment:self.addressComment userName:self.userName domain:self.domain];
}

- (BOOL)isEqualTo:(id)object {
	if ([object isKindOfClass:[MKEmailAddress class]]) {
		return [self.displayAddress isEqualToString:((MKEmailAddress *)object).displayAddress];
	}
	else {
		return NO;
	}
}
- (BOOL)isEqual:(id)object {
	return [self isEqualTo:object];
}

- (NSUInteger)hash {
	return [self.displayAddress hash];
}

- (NSString *)rfc2822Representation {
	if (self.addressComment){
		NSString * escapedQuotedComment = [self.addressComment stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		
		if (self.userAtDomain){
			if ([self.addressComment canBeConvertedToEncoding:NSASCIIStringEncoding]){
				return [NSString stringWithFormat:@"\"%@\" <%@>",escapedQuotedComment,self.userAtDomain];
			}
			else{
				NSString * encodedComment = [NSString mimeWordWithString:self.addressComment preferredEncoding:NSISOLatin1StringEncoding encodingUsed:nil];
				return [NSString stringWithFormat:@"\"%@\" <%@>",encodedComment,self.userAtDomain];
			}
		}
		else{
			// technically this is not RFC2822 compliant as there is no user@domain portion
			if ([self.addressComment canBeConvertedToEncoding:NSASCIIStringEncoding]){
				return [NSString stringWithFormat:@"\"%@\"",escapedQuotedComment];
			}
			else{
				NSString * encodedComment = [NSString mimeWordWithString:self.addressComment preferredEncoding:NSISOLatin1StringEncoding encodingUsed:nil];
				return [NSString stringWithFormat:@"\"%@\"",encodedComment];
			}
		}
	}
	else{
		return self.userAtDomain;
	}
}

@end


#pragma mark - Category Stuff

@implementation NSData(MKE_MKEmailAddress)
- (NSString *)MKEpathSafeBase64EncodedString {
	
	if ([self respondsToSelector:@selector(base64EncodedStringWithOptions:)]){
		NSString    *cleaned = [[self base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
		cleaned = [cleaned stringByReplacingOccurrencesOfString:@"+" withString:@"_"];
		return cleaned;
	}
	else{
		const char* input =  [self bytes];
		NSInteger length = [self length];
		
		static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=";
		
		NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
		uint8_t* output = (uint8_t*)data.mutableBytes;
		
		NSInteger i;
		for (i=0; i < length; i += 3) {
			NSInteger value = 0;
			NSInteger j;
			for (j = i; j < (i + 3); j++) {
				value <<= 8;
				if (j < length) {
					value |= (0xFF & input[j]);
				}
			}
			
			NSInteger theIndex = (i / 3) * 4;
			output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
			output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
			output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
			output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
		}
		return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] ;
	}
}
@end

@implementation NSString(MKE_MKEmailAddress)

- (NSString *)MKEshortSHAHashString {
#define ID_SIZE 12
	// Size 12 = 72 bits = number of inputs to have a 50% chance of collision: 8.09*10^10 (80.9 billion)
	// number of input will be much greater once there are constraints to the inputs.
	
	const char *s=[self cStringUsingEncoding:NSUTF8StringEncoding];
	
	uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
	CC_SHA256(s, (CC_LONG)strlen(s), digest);
	
	NSData * digestData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
	
	NSString * generatedID =[[digestData MKEpathSafeBase64EncodedString] substringToIndex:ID_SIZE];
	return generatedID;
}

@end
